class ApplyController < ApplicationController
  before_action :authenticate_user!

  # 모임 신청
  def create
    boardID = params[:boardID]
    board = Board.find(boardID)
    boardMaster = User.find(board.user_id)

    Apply.create(board_id: boardID , user_id: current_user.id , message: params[:message])

    if current_user.receiveNotice
      noticeMessage = "<a href='/board/#{board.id}/stream'>#{board.title} 모임에 가입 신청을 보냈습니다.</a>"
      Notice.create(user_id: current_user.id , message: noticeMessage)
    end

    if boardMaster.receiveNotice
      noticeMessage = "<a href='/board/#{board.id}/groupInfo'>#{board.title} 모임에 가입 신청이 도착했습니다.</a>"
      Notice.create(user_id: boardMaster.id , message: noticeMessage)
    end

    redirect_to "/board/#{boardID}/stream"
  end


  # 모임 신청 취소
  def cancle
    applyModule
    boardMaster = User.find(@board.user_id)

    if boardMaster.receiveNotice
      noticeMessage = @board.title + " 모임에서 누군가가 가입 신청을 취소했습니다."
      Notice.create(user_id: boardMaster.id , message: noticeMessage)
    end

    @apply.destroy
    redirect_to "/board/#{@boardID}/stream"
  end


  # 모임 신청 거절
  def reject
    applyModule
    user = @apply.user

    if user.receiveNotice
      noticeMessage = "<a href='/board/#{@boardID}/stream'>#{@board.title} 모임 가입 신청이 거절되었습니다.</a>"
      Notice.create(user_id: user.id , message: noticeMessage)
    end

    @apply.destroy
    redirect_to "/board/#{@boardID}/groupInfo"
  end


  # 모임 신청서 승낙
  def accept
    applyModule
    user = @apply.user

    @board.update_attributes(memberCount: @board.memberCount + 1)     # 모임의 인원 수를 1 증가
    user.update_attributes(board_count: user.board_count + 1)         # 유저가 갖는 게시판의 수를 1 증가

    AcceptApply.create(user_id: user.id , board_id: @boardID)
    @apply.destroy

    if user.receiveNotice
      noticeMessage = "<a href='/board/#{@boardID}/stream'>#{@board.title} 모임에 가입되었습니다.</a>"
      Notice.create(user_id: user.id , message: noticeMessage)
    end

    redirect_to "/board/#{@boardID}/groupInfo"
  end


  private

  def applyModule
    @apply = Apply.find(params[:applyID])

    @boardID = @apply.board.id
    @board = Board.find(@boardID)
  end
end
