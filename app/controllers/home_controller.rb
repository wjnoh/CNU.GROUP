class HomeController < ApplicationController
  before_action :authenticate_user! , only: [:destroyNotice, :changeProfileImage_path]

  def main
    @sayhello = ["안녕하세요!", "Hello!", "こんにちは!", "您好!", "Bonjour!", "Hola!", "Guten Tag!", "Xin chào!", "Buon giorno!", "Apa kabar!"].sample

    # 모든 게시글 중 최신 게시글 10개
    @recentBoards = Board.all.reverse.take(10)

    # 모든 게시글의 수를 계산하는 영역
    if !user_signed_in?
      @allPostCount = Board.count

    # 현재시간과 참여하고 있는 각 게시판의 마지막 글 등록시간과의 차이를 계산하는 영역
    else
      # 유저의 게시판 개수
      @user = User.find(current_user.id)
      @userHavingBoardList = @user.accept_applies.reverse
      @userBoardCount = @userHavingBoardList.length
      @userNotices = @user.notices.reverse

      # 참여한 게시판이 없으면 함수를 종료한다.
      @emptyBoardList = false
      if @userHavingBoardList[0].nil?
        @emptyBoardList = true
        return
      end

      # 최근 작성된 게시글과 @message를 hash로 저장한다.
      @hashBoardAndMessage = Hash.new
      @message = ""

      for i in 0..@userHavingBoardList.length-1
        stream = Post.where(board_id: @userHavingBoardList[i].board.id)

        if stream.empty?
          @message = "작성된 글이 없습니다."
          @hashBoardAndMessage.store("#{@userHavingBoardList[i].board.id}", @message)
          next
        end

        oneMin = 60
        oneHour = oneMin*60
        oneDay = oneHour*24
        oneMonth = oneDay*30
        oneYear = oneMonth*12

        recentPost = stream[stream.length-1]                            # 최근 작성된 게시글
        recentPostTime = recentPost.created_at.to_s                         # 최근 작성된 게시글의 시간
        diffTotalTime = (Time.now - Time.parse(recentPostTime)).floor       # 현재시간 - 최근 작성된 게시글의 시간

        # 초
        if diffTotalTime < oneMin
          @message = "방금 전에 새 글이 작성되었습니다."
        # 분
        elsif diffTotalTime < oneHour
          diffTotalTime = (diffTotalTime/oneMin).floor
          @message = diffTotalTime.to_s + "분 전에 새 글이 작성되었습니다."
        # 시간
        elsif diffTotalTime < oneDay
          diffTotalTime = (diffTotalTime/oneHour).floor
          @message = diffTotalTime.to_s + "시간 전에 새 글이 작성되었습니다."
        # 일
        elsif diffTotalTime < oneMonth
          diffTotalTime = (diffTotalTime/oneDay).floor
          @message = diffTotalTime.to_s + "일 전에 새 글이 작성되었습니다."
        # 개월
        elsif diffTotalTime < oneYear
          diffTotalTime = (diffTotalTime/oneMonth).floor
          @message = diffTotalTime.to_s + "개월 전에 새 글이 작성되었습니다."
        # 년
        else
          diffTotalTime = (diffTotalTime/oneYear).floor
          @message = diffTotalTime.to_s + "년 전에 새 글이 올라왔습니다."
        end

        @hashBoardAndMessage.store("#{@userHavingBoardList[i].board.id}", @message)
      end
    end
  end


  # 게시판 검색
  def searchBoard
    if params[:category] == "모든 관심사"
      @boards = Board.where("title LIKE ? " , "%#{params[:searchBoardName]}%" )
    else
      @boards = Board.where(["title LIKE ? AND category LIKE ?" , "%#{params[:searchBoardName]}%" , "%#{params[:category]}%"])
    end

    if current_user.nil?
      respond_to do |format|
          format.js
      end
      # 로그인 안 한상태에서는 유저와 게시판의 상태관계를 확인 할 필요가 없다.
      return;
    end

    # 검색결과 각 게시판에서 현재 접속유저의 게시판 신청 상태를 저장하는 배열
    @applies = []
    for i in 0..@boards.length-1
      next   if @boards[i].applies.find_by(user_id: current_user.id).nil?
      @applies[i] = @boards[i].id    if @boards[i].applies.find_by(user_id: current_user.id).user == current_user
    end

    # 검색결과 각 게시판에서 현재 접속유저가 게시판에 가입되어 있는지 저장하는 배열
    @acceptApplies = []
    for i in 0..@boards.length-1
      next  if @boards[i].accept_applies.find_by(user_id: current_user.id).nil?
      @acceptApplies[i] = @boards[i].id   if @boards[i].accept_applies.find_by(user_id: current_user.id).user == current_user
    end

    @fullMember = []
    for i in 0..@boards.length-1
      @fullMember[i] = @boards[i].id   if @boards[i].memberCount == @boards[i].totalNumberOfMember
    end

    respond_to do |format|
        format.js
    end
  end


  # 알림 삭제
  def destroyNews
    user = User.find(current_user.id)
    userNotices = user.notices
      userNotices.each do |userNotice|
        userNotice.destroy
      end
    redirect_to "/home/main"
  end


  # 알림 켜기 / 끄기
  def onOffNews
    @status = params[:status]
    if @status == "off"
      current_user.update_attributes(receiveNotice: false)
    else
      current_user.update_attributes(receiveNotice: true)
    end

    redirect_to "/home/main"
  end


  # 프로필사진 변경
  def changeProfileImage
    getFile = params[:fileName]   # 파일을 받는 변수
    originFileName =""

    originFileName = getFile.original_filename
    fileExtension = File.extname(originFileName)
    getFile.original_filename = [*('A'..'Z')].sample(20).join + fileExtension

    # AWS 저장 영역
    uploader = StorageUploader.new
    uploader.store!(getFile)

    # 저장된 파일 AWS URL
    fileURL = "https://s3.ap-northeast-2.amazonaws.com/cnu.group/uploads/" + getFile.original_filename
    current_user.update_attributes(profile_picture: fileURL)

    redirect_to "/home/main"
  end


  # 기본 프로필 사진 바꾸기
  def changeBasicProfileImage
    profileURL = params[:profileURL]
    user = User.find(current_user.id)
    user.update_attributes(profile_picture: profileURL)

    redirect_to "/home/main"
  end

end
