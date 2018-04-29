require "Common_controller_module"
class PostController < ApplicationController
  include SetWriter
  before_action :authenticate_user!
  # 이미 인증이 되어있으므로 삭제를 할 경우 인증 토큰을 검사할 필요가 없다.
  skip_before_action :verify_authenticity_token , only: [:destroyReply]


  # 게시글 생성
  def create
    boardID = params[:boardID]
    @getFile = params[:createFilename]   # 파일을 받는 변수
    @originFileName = ""                 # 파일의 원래 이름을 저장할 변수

    unless @getFile.nil?                 # AWS에 중복저장되는 것을 방지하기 위해 getFile의 이름을 바꾼다.
      awsModule
    end

    Post.create(user_id: current_user.id, board_id: boardID, writer: current_user.name, modifyFileName: @getFile,
                  originalFileName: @originFileName ,content: params[:createContent], title: params[:createTitle])

    redirect_to "/board/#{boardID}/stream"
  end


  # 게시글 수정
  def update
    @getFile = params[:updateFilename]   # 파일을 받는 변수
    @originFileName = ""                 # 파일의 원래 이름을 저장할 변수

    boardID = params[:boardID]
    post = Post.find(params[:postID])

    unless @getFile.nil?                 # AWS에 중복저장되는 것을 방지하기 위해 getFile의 이름을 바꾼다.
      awsModule
      post.update_attributes(modifyFileName: @getFile, originalFileName: @originFileName,
                              content: params[:updateContent], title: params[:updateTitle])
    else
      post.update_attributes(content: params[:updateContent], title: params[:updateTitle])
    end

    if post.info == true
      return redirect_to "/board/#{boardID}/groupInfo"
    else
      return redirect_to "/board/#{boardID}/stream"
    end
  end


  # 게시글 삭제
  def destroy
    if checkMyPost
      # info post는 무조건 1개여야 하므로 지울 수 없다.
      if @post.info
        return redirect_to "/board/#{@boardID}/stream"
      end

      # 게시글의 모든 댓글 DB 삭제
      replies = @post.replies
      replies.each do |reply|
        reply.destroy
      end

      @post.destroy
    end
    redirect_to "/board/#{@boardID}/stream"
  end


  # 공지 등록
  def createNotice
    return redirect_to "/board/#{@boardID}/stream" unless checkMyPost

    post = Post.find(params[:postID])
    post.update_attributes(notice: true)

    boardID = post.board.id
    board = Board.find(boardID)

    accept_applies = board.accept_applies
    accept_applies.each do |accept_apply|
      user = accept_apply.user
      if user.receiveNotice
        noticeMessage = "<a href='/board/#{board.id}/notice'>#{board.title} 모임에 새로운 공지글이 작성되었습니다.</a>"
        Notice.create(user_id: user.id , message: noticeMessage)
      end
    end

    redirect_to "/board/#{boardID}/stream"
  end


  # 공지 해제
  def deleteNotice
    @post.update_attributes(notice: false) if checkMyPost
    redirect_to "/board/#{@boardID}/stream"
  end


  # 댓글 생성 (스트림 / 익명게시판)
  def createReply
    @postID = params[:postID]
    @category = params[:category]

    # 스트림
    if @category.nil?
      @post = Post.find(@postID)
      @reply = Reply.create(user_id: current_user.id, post_id: @postID,
                            replyWriter: current_user.name, replyContent: params[:replyContent])
      createMessageForStream

    # 익명게시판
    # FIXME 익명작성자의 중복이 심할 경우 중복검사 코드 작성 할 것 - 현재는 성능을 위해 중복검사 생략
    else
      setWriter

      if @category == "자유게시판"
        @post = Freepost.find(@postID)
        finalSetReplyWriter
        @reply = Reply.create(user_id: current_user.id, freepost_id: @postID,
                              replyWriter: @replyWriter, replyContent: params[:replyContent])
        createMessageForAnonyboard

      elsif @category == "홍보게시판"
        @post = Adpost.find(@postID)
        finalSetReplyWriter
        @reply = Reply.create(user_id: current_user.id, adpost_id: @postID,
                              replyWriter: @replyWriter, replyContent: params[:replyContent])
        createMessageForAnonyboard

      else              # 질문게시판
        @post = Suggestionpost.find(@postID)
        finalSetReplyWriter
        @reply = Reply.create(user_id: current_user.id, suggestionpost_id: @postID,
                              replyWriter: @replyWriter, replyContent: params[:replyContent])
        createMessageForAnonyboard
      end
    end

    respond_to do |format|
      format.js
    end
  end


  # 댓글 삭제 (스트림 / 익명게시판)
  def destroyReply
    reply = Reply.find(params[:replyID])

    # 스트림
    unless reply.post.nil?
      boardID = reply.post.board.id
      reply.destroy if reply.user == current_user
      redirect_to "/board/#{boardID}/stream"

    # 익명게시판 (사실 redirect를 어떤 path를 두던 상관없다 - ajax로 댓글삭제하므로)
    else
      reply.destroy if reply.user == current_user

      if reply.freepost.nil?
        redirect_to "/freeBoard"
      elsif reply.adpost.nil?
        redirect_to "/adBoard"
      else
        redirect_to "/suggestion"
      end
    end
  end



  private

  # 파일의 이름을 바꿔서 aws에 전송하기 위한 모듈
  def awsModule
    @originFileName = @getFile.original_filename
    fileExtension = File.extname(@originFileName)
    @getFile.original_filename = [*('A'..'Z')].sample(20).join + fileExtension


    # AWS 저장 영역
    uploader = StorageUploader.new
    uploader.store!(@getFile)
  end


  # 나의 게시글인지 체크하는 모듈
  def checkMyPost
    @post = Post.find(params[:postID])
    @postUser = @post.user
    @boardID = @post.board.id

    unless @postUser == current_user
      return false
    end

    return true
  end


  # 익명 게시판의 댓글 작성자를 최종 결정 (현재 유저가 해당 게시글에 댓글을 작성했으면 기존의 별명을 유지)
  def finalSetReplyWriter
    if @post.user_id == current_user.id
      @replyWriter = @post.writer
    else
      replies = @post.replies
      currentUserReply = replies.find_by(user_id: current_user.id)   unless replies.empty?
      if currentUserReply.nil?
        @replyWriter = @writer
      else
        @replyWriter = currentUserReply.replyWriter
      end
    end
  end


  # 스트림에서 메시지를 생성
  def createMessageForStream
    postWriterID = @post.user.id
    board = @post.board
    title = @post.title

    if @post.title.length > 10
      title = @post.title.slice(0,5) + "..."
    end

    # 글쓴이는 모든 댓글에 대해 메시지를 받음 (자신의 댓글 제외)
    if postWriterID != @reply.user.id &&  @post.user.receiveNotice
      noticeMessage = "<a href='/board/go/#{board.id}/#{@post.id}/stream'>#{board.title} 모임의 \"#{title}\" 글에
                         댓글이 달렸습니다.</a>"
      Notice.create(user_id: postWriterID , message: noticeMessage)
    end

    # 게시글에 댓글을 등록한 모든 구성원(방금 댓글을 작성한 유저를 제외한)은 메시지를 받음
    createUniqUserModule

    @uniqUsersID.each do |replyUser|
      if replyUser.receiveNotice
        noticeMessage = "<a href='/board/go/#{board.id}/#{@post.id}/stream'>#{board.title} 모임의 \"#{title}\" 글에
                           댓글이 달렸습니다.</a>"
        Notice.create(user_id: replyUser , message: noticeMessage)
      end
    end
  end


  # 익명게시판에서 메시지 생성
  def createMessageForAnonyboard
    postWriterID = @post.user.id
    title = @post.title
    if title.length > 10
      title = title.slice(0,10) + "..."
    end

    if @category == "자유게시판"
      if postWriterID != @reply.user.id && @post.user.receiveNotice
        noticeMessage = "<a href='/freeBoard/go/#{@postID}'>자유게시판 \"#{title}\" 글에 댓글이 달렸습니다.</a>"
        Notice.create(user_id: postWriterID , message: noticeMessage)
      end
      createUniqUserModule
      @uniqUsersID.each do |replyUser|
        if replyUser.receiveNotice
          noticeMessage = "<a href='/freeBoard/go/#{@postID}'>자유게시판 \"#{title}\" 글에 댓글이 달렸습니다.</a>"
          Notice.create(user_id: replyUser , message: noticeMessage)
        end
      end

    elsif @category == "홍보게시판"
      if postWriterID != @reply.user.id && @post.user.receiveNotice
        noticeMessage = "<a href='/adBoard/go/#{@postID}'>홍보게시판 \"#{title}\" 글에 댓글이 달렸습니다.</a>"
        Notice.create(user_id: postWriterID , message: noticeMessage)
      end
      createUniqUserModule
      @uniqUsersID.each do |replyUser|
        if replyUser.receiveNotice
          noticeMessage = "<a href='/adBoard/go/#{@postID}'>홍보게시판 \"#{title}\" 글에 댓글이 달렸습니다.</a>"
          Notice.create(user_id: replyUser , message: noticeMessage)
        end
      end

    else
      if postWriterID != @reply.user.id && @post.user.receiveNotice
        noticeMessage = "<a href='/suggestion/go/#{@postID}'>질문게시판 \"#{title}\" 글에 댓글이 달렸습니다.</a>"
        Notice.create(user_id: postWriterID , message: noticeMessage)
      end
      createUniqUserModule
      @uniqUsersID.each do |replyUser|
        if replyUser.receiveNotice
          noticeMessage = "<a href='/suggestion/go/#{@postID}'>질문게시판 \"#{title}\" 글에 댓글이 달렸습니다.</a>"
          Notice.create(user_id: replyUser , message: noticeMessage)
        end
      end
    end
  end

  # 중복되지 않은 유저들로 구성된 배열
  def createUniqUserModule
    @uniqUsersID = []
    @post.replies.each do |reply|
      replyUserID = reply.user.id
      next        unless @uniqUsersID.include? replyUserID || @reply.user.id == replyUserID
      @uniqUsersID.push(replyUserID)
    end
  end


end
