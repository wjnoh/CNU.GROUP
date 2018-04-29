Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations' }
  root "home#main"

# home 컨트롤러
  get   "home/main"
  post  "home/board"        => "home#searchBoard"
  delete"home/news"         => "home#destroyNews"
  patch "home/news/:status" => "home#onOffNews"
  patch "home/profileImg"   => "home#changeProfileImage"
  patch "home/basicImg"     => "home#changeBasicProfileImage"


# classroom 컨트롤러
  get "classroom"                     => "classroom#search"
  get "classroom/college/:college"    => "classroom#search"
  get "classroom/day/:day"            => "classroom#search"
  get "classroom/theClass/:theClass"  => "classroom#search"


# board 컨트롤러
  get   "board/:boardID/stream"               => "board#stream"
  get   "board/:boardID/:postID/stream"       => "board#stream"
  get   "board/:link/:boardID/:postID/stream" => "board#stream"
  post  "board"             => "board#create"
  patch "board"             => "board#update"
  delete"board/:boardID"    => "board#destroy"

  # 공지 목록
  get   "board/:boardID/notice"       => "board#notice"
  # 모임 정보
  get   "board/:boardID/groupInfo"    => "board#groupInfo"
  # 모임 탈퇴
  delete"board/:boardID/self"         => "board#leave"
  # 마스터 양도
  patch "board/master/:acceptApplyID" => "board#transferMaster"
  # 유저 강퇴
  delete"board/user/:acceptApplyID"   => "board#excludeUser"
  # 게시판 검색
  get  "board/:boardID/searchList/:searchContent"   => "board#searchList"
  post "board/:boardID/searchList/:searchContent"   => "board#searchList"

  # 그룹 시간표
  get "board/:boardID/membersTimetable"   => "board#membersTimetable"
  post "board/:boardID/analysisTimetable" => "board#analysisTimetable"


# post 컨트롤러
  post  "post"          => "post#create"
  patch "post"          => "post#update"
  delete"post/:postID"  => "post#destroy"

  # tinymce
  post '/tinymce_assets' => 'tinymce_assets#create'

  # 공지
  post  "post/:postID/notice" => "post#createNotice"
  delete"post/:postID/notice" => "post#deleteNotice"

  # 댓글
  post  "post/reply"          => "post#createReply"
  delete"post/reply/:replyID" => "post#destroyReply"



# apply
  post   "apply"               => "apply#create"
  patch  "apply/:applyID"      => "apply#accept"
  delete "apply/:applyID/self" => "apply#cancle"
  delete "apply/:applyID"      => "apply#reject"


# timetable
  get   "timetable"                   => "timetable#new"
  get   "timetable/:timetableID"      => "timetable#show"
  post  "timetable"                   => "timetable#create"
  patch "timetable/:timetableID/main" => "timetable#main"
  delete"timetable/:timetableID"      => "timetable#delete"


# anonyBoard
  get     "freeBoard"         => "free_board#new"
  get     "freeBoard/:postID" => "free_board#new"
  get     "freeBoard/:link/:postID" => "free_board#new"
  post    "freeBoard"         => "free_board#create"
  patch   "freeBoard"         => "free_board#update"
  delete  "freeBoard/:postID" => "free_board#destroy"
  get     "freeBoard/searchList/:searchContent"   => "free_board#searchList"
  post    "freeBoard/searchList/:searchContent"   => "free_board#searchList"

  get     "adBoard"         => "ad_board#new"
  get     "adBoard/:postID" => "ad_board#new"
  get     "adBoard/:link/:postID" => "ad_board#new"
  post    "adBoard"         => "ad_board#create"
  patch   "adBoard"         => "ad_board#update"
  delete  "adBoard/:postID" => "ad_board#destroy"
  get     "adBoard/searchList/:searchContent"   => "ad_board#searchList"
  post    "adBoard/searchList/:searchContent"   => "ad_board#searchList"

  get     "suggestion"         => "suggestion_board#new"
  get     "suggestion/:postID" => "suggestion_board#new"
  get     "suggestion/:link/:postID" => "suggestion_board#new"
  post    "suggestion"         => "suggestion_board#create"
  patch   "suggestion"         => "suggestion_board#update"
  delete  "suggestion/:postID" => "suggestion_board#destroy"
  get     "suggestion/searchList/:searchContent"   => "suggestion_board#searchList"
  post    "suggestion/searchList/:searchContent"   => "suggestion_board#searchList"


  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
