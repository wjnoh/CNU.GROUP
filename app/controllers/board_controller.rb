class BoardController < ApplicationController
  before_action :authenticate_user! , except: [:stream]
  before_action :checkMember , only: [:notice, :searchList, :groupInfo, :analysisTimetable, :membersTimetable ]

  # 게시글 목록
  def stream
    groupNavMoudle
    if @belongsToMember
      @posts = @board.posts.order('created_at DESC').paginate(:page => params[:page], :per_page => 5)
      @postsByCurrentUser = @posts.where(user_id: current_user.id) unless current_user.nil?

      linkStatus = params[:link]
      @choosenPostID = params[:postID].to_i unless params[:postID].nil?

      if linkStatus == "go"
        countAboveChoosenPost = 0
        @board.posts.reverse.each do |post|
          if @choosenPostID >= post.id
            break
          else
            countAboveChoosenPost = countAboveChoosenPost + 1
          end
        end
        page = (countAboveChoosenPost / 5.0).floor + 1

        return redirect_to "/board/#{@board.id}/#{@choosenPostID}/stream?page=#{page}"
      end

    else
      @infoPost = @board.posts.find_by(info: true)
    end
  end

  # 모임 생성
  def create
    user = User.find(current_user.id)
    user.update_attributes(board_count: user.board_count + 1)

    board = Board.create(user_id: user.id , title: params[:boardName] , category: params[:category],
                          info: params[:groupInfo] , totalNumberOfMember: params[:totalNumberOfMember] , memberCount: 1)

    # 게시판 생성 시 첫 게시글 seed
    seedPostWriter = "관리자"
    seedPostTitle = "환영합니다!"
    seedPostContent = " <p style='text-align: justify;'>
                        이 가상 공간에서는 스트림을 통해 구성원들과 게시글을 주고받고 파일도 전송 할 수 있습니다.
                        또한 구성원들의 스케줄을 분석하고 싶을 때는 시간표 메뉴의 분석하기 기능을 활용해보세요!
                        </p>
                        <p style='text-align: justify;'>
                        * 마스터 * <br>
                        공지사항을 작성하시려면 게시글을 작성한 뒤 게시글 우상단에 위치한 \"공지\" 버튼을 클릭하시면 됩니다.
                        또한 마스터는 모임 정보 및 외부 유저에게 보여지는 모임 소개 글을 수정 할 수 있고,
                        외부 유저의 모임 신청을 관리 할 수 있으며, 모임의 분위기를 흐리거나 부적절한 구성원이 있다면 추방할 수도 있습니다.
                        마스터가 모임을 탈퇴하기 위해서는 반드시 누군가에게 마스터를 양도해야 합니다.
                        마지막으로 \"모임삭제\" 버튼을 누르면 모임이 삭제되므로 주의하시기 바랍니다!
                        </p>
                        <p style='text-align: justify;'>
                        구성원들의 활발한 활동을 기대하겠습니다! :)
                        </p> "
    Post.create(user_id: user.id, board_id: board.id, writer: seedPostWriter, title: seedPostTitle,
                  content: seedPostContent , notice: true)

    # 모임원이 아닌 사람에게 보여주는 소개카드
    seedInfoPostWriter = "#{user.name}"
    seedInfoPostTitle = "환영합니다!"
    seedInfoPostContent = "<p>#{board.title} 모임입니다.</p>
                           <p>가입을 원하시면 좌측에 있는 신청 버튼을 눌러주세요!</p>
                           "
    Post.create(user_id: user.id, board_id: board.id, writer: seedInfoPostWriter, title: seedInfoPostTitle,
                  content: seedInfoPostContent , info: true)

    # 모임장도 신청서가 승낙된 상태라고 생각
    AcceptApply.create(user_id: user.id , board_id: board.id)

    if user.receiveNotice
      noticeMessage = "<a href='/board/#{board.id}/stream'>#{board.title} 모임을 생성했습니다.</a>"
      Notice.create(user_id: user.id , message: noticeMessage)
    end

    redirect_to "/board/#{board.id}/stream"
  end


  # 모임 수정
  def update
    board = Board.find(params[:boardID])
    board.update_attributes(title: params[:boardName], info: params[:groupInfo],
                              totalNumberOfMember: params[:totalNumberOfMember], category: params[:category] )
    boardID = board.id

    redirect_to "/board/#{boardID}/groupInfo"
  end


  # 모임 삭제
  def destroy
    return redirect_to "/" unless checkMasterForDestroy

    board = Board.find(params[:boardID])
    acceptApplies = AcceptApply.where(board_id: board.id)

    # 모임의 모든 구성원 DB 삭제
    acceptApplies.each do |acceptApply|
      user = acceptApply.user
      user.update_attributes(board_count: user.board_count - 1)

      if user.receiveNotice
        noticeMessage = board.title + " 모임이 삭제되었습니다."
        Notice.create(user_id: user.id , message: noticeMessage)
      end

      acceptApply.destroy
    end

    # 모임의 모든 게시글 DB삭제
    posts = board.posts
    posts.each do |post|
      post.destroy
    end

    board.destroy
    redirect_to "/home/main"
  end


  # 공지글 리스트
  def notice
    groupNavMoudle
    @posts = @board.posts.where(notice: true).order('created_at DESC').paginate(:page => params[:page], :per_page => 5)

    @postsByCurrentUser = @posts.where(user_id: current_user.id)

  end


  # 게시글 검색
  def searchList
    groupNavMoudle
    @searchContent = params[:searchContent]
    @posts = @board.posts.where("title LIKE ? " , "%#{@searchContent}%" ).order('created_at DESC').paginate(:page => params[:page], :per_page => 5)
    @postsByCurrentUser = @posts.where(user_id: current_user.id)
  end


  # 마스터 양도
  def transferMaster
    return redirect_to "/" unless checkMasterForETC

    originMasterID = @board.user_id

    newMasterID = @accept_apply.user.id
    newMaster = User.find(newMasterID)
    newMasterName = newMaster.name
    @board.update_attributes(user_id: newMasterID)

    infoPost = @board.posts.find_by(info: true)
    infoPost.update_attributes(writer: newMasterName)

    if User.find(originMasterID).receiveNotice
      noticeMessage = "<a href='/board/#{@board.id}/groupInfo'>#{@board.title} 모임의 마스터를 #{newMasterName}님에게 양도했습니다.</a>"
      Notice.create(user_id: originMasterID , message: noticeMessage)
    end

    if newMaster.receiveNotice
      noticeMessage = "<a href='/board/#{@board.id}/groupInfo'>#{@board.title} 모임의 마스터가 되었습니다.</a>"
      Notice.create(user_id: newMasterID , message: noticeMessage)
    end

    return redirect_to "/board/#{@board.id}/groupInfo"
  end


  # 강퇴
  def excludeUser
    return redirect_to "/" unless checkMasterForETC

    @board.update_attributes(memberCount: @board.memberCount - 1)

    user = @accept_apply.user
    user.update_attributes(board_count: user.board_count - 1)

    if user.receiveNotice
      noticeMessage = @board.title + " 모임에서 추방되었습니다."
      Notice.create(user_id: user.id , message: noticeMessage)
    end

    @accept_apply.destroy
    return redirect_to "/board/#{@board.id}/groupInfo"
  end


  # 게시판 정보
  def groupInfo
    groupNavMoudle
    @boardCategory = @board.category
    @infoPost = @board.posts.find_by(info: true)

    @applyEmpty = false
    @applyEmpty = true if @board.applies[0].nil?
  end


  # 모임 탈퇴
  def leave
    board = Board.find(params[:boardID])
    acceptApply = board.accept_applies.find_by(user_id: current_user.id)
    return redirect_to "/" if acceptApply.nil?

    acceptApply.destroy

    userID = acceptApply.user.id
    user = User.find(userID)
    user.update_attributes(board_count: user.board_count - 1)
    board.update_attributes(memberCount: board.memberCount - 1)

    if user.receiveNotice
      noticeMessage = board.title + " 모임을 탈퇴했습니다."
      Notice.create(user_id: userID , message: noticeMessage)
    end

    if User.find(board.user_id).receiveNotice
      noticeMessage = "<a href='/board/#{@board.id}/groupInfo'>#{board.title} 모임에서 #{user.name}님이 탈퇴했습니다.</a>"
      Notice.create(user_id: board.user_id , message: noticeMessage)
    end

    redirect_to "/home/main"
  end


  # 구성원들의 시간표
  def membersTimetable
    groupNavMoudle
    @masterTimetable  = @boardMaster.timetables.find_by(main: true)

    # 각 유저마다 대표 시간표를 배열로 저장
    @users = []
    @timetables = []
    for i in 0..@board.accept_applies.length-1
      @users[i] = @board.accept_applies[i].user
      @timetables[i] = @users[i].timetables.find_by(main: true)
    end
  end


  # 구성원들의 시간표 분석
  def analysisTimetable
    groupNavMoudle

    @day = ["월", "화", "수", "목", "금", "토", "일"]
    @time = ["09_00", "09_30", "10_00", "10_30", "11_00", "11_30", "12_00", "12_30", "13_00", "13_30", "14_00", "14_30", "15_00", "15_30", "16_00", "16_30", "17_00", "17_30", "18_00", "18_30", "19_00", "19_30", "20_00", "20_30", "21_00", "21_30", "22_00", "22_30", "23_00", "23_30", "24_00"]
    @index = [1, 2, 3, 4, 5, 6, 7]

    @timetable = []
    @a = Array.new
    i = 0
    params[:analisys].keys.each do |key|
      @timetable[i] = Timetable.find(key)
      @a[i] = key
      i += 1
    end
  end


  private


  def groupNavMoudle
    @board = Board.find(params[:boardID])
    @boardID = @board.id
    @boardTitle = @board.title
    @boardMaster = User.find(@board.user_id)

    @fullMember = false
    @fullMember = true if @board.memberCount >= @board.totalNumberOfMember

    @alreadyApply = false
    for i in 0..@board.applies.length-1
      if @board.applies[i].user == current_user
        @alreadyApply = true
        @applyID = @board.applies[i].id
        break
      end
    end

    @belongsToMember = false
    for i in 0..@board.accept_applies.length-1
      if @board.accept_applies[i].user == current_user
        @belongsToMember = true
        break
      end
    end
  end


  # 그룹의 멤버인지 확인 => 멤버가 아니면 스트림으로 리다이렉트
  def checkMember
    @board = Board.find(params[:boardID])
    @boardID = @board.id

    @belongsToMember = false
    for i in 0..@board.accept_applies.length-1
      if @board.accept_applies[i].user == current_user
        @belongsToMember = true
        break
      end
    end

    redirect_to "/board/#{@boardID}/stream" unless @belongsToMember
  end


  # 현재 유저가 마스터인지 체크 => 삭제권한 부여
  def checkMasterForDestroy
    @boardID = params[:boardID]
    @board = Board.find(@boardID)

    if @board.user_id == current_user.id
      return true
    end
    return false
  end


  # 현재 유저가 마스터인지 체크 => 권한 부여
  def checkMasterForETC
    @accept_apply = AcceptApply.find(params[:acceptApplyID])
    @board = @accept_apply.board

    if @board.user_id == current_user.id
      return true
    end
    return false
  end

end
