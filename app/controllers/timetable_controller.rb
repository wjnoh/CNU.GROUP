class TimetableController < ApplicationController
  before_action :authenticate_user!
  before_action :checkMyTimetable , only: [:show]

  # 시간표 작성 뷰 페이지
  def new
    @day = ["월", "화", "수", "목", "금", "토", "일"]
    @time = ["09_00", "09_30", "10_00", "10_30", "11_00", "11_30", "12_00", "12_30", "13_00", "13_30", "14_00", "14_30", "15_00", "15_30", "16_00", "16_30", "17_00", "17_30", "18_00", "18_30", "19_00", "19_30", "20_00", "20_30", "21_00", "21_30", "22_00", "22_30", "23_00", "23_30", "24_00"]
    @index = [1, 2, 3, 4, 5, 6, 7]

    xlsx = Roo::Spreadsheet.open('public/CNUtimetable.xlsx').column(1) - [" ", nil]

    for i in xlsx.length.downto(0)
      perfectString = xlsx[i].to_s + "+#{perfectString}"
    end

    @timetable = current_user.timetables
    @perfectString = perfectString.split("+")
  end


  # 시간표 생성
  def create
    checkMainTable = current_user.timetables.find_by(main: true)

    if checkMainTable.nil?
      Timetable.create(user_id: current_user.id, title: params[:title] , main: true)
    else
      Timetable.create(user_id: current_user.id, title: params[:title])
    end

    params[:ttcell].keys.each do |key|
          @ttcell = Ttcell.new
          @ttcell.cellId = key
          @ttcell.timetable_id = Timetable.last.id
      params[:cellName].keys.each do |cellId|
        if (@ttcell.cellId) == cellId
          params[:cellName][cellId].keys.each do |rowSpan|
            params[:cellName][cellId][rowSpan].keys.each do |colSpan|
              params[:cellName][cellId][rowSpan][colSpan].keys.each do |cellColor|
                @ttcell.cellName = params[:cellName][cellId][rowSpan][colSpan][cellColor]
                @ttcell.rowSpan = rowSpan
                @ttcell.colSpan = colSpan
                @ttcell.cellColor = cellColor
              end
            end
          end
        end
          @ttcell.save
      end
    end
    redirect_to "/timetable"
  end


  # 특정 시간표 출력
  def show
    @day = ["월", "화", "수", "목", "금", "토", "일"]
    @time = ["09_00", "09_30", "10_00", "10_30", "11_00", "11_30", "12_00", "12_30", "13_00", "13_30", "14_00", "14_30", "15_00", "15_30", "16_00", "16_30", "17_00", "17_30", "18_00", "18_30", "19_00", "19_30", "20_00", "20_30", "21_00", "21_30", "22_00", "22_30", "23_00", "23_30", "24_00"]
    @index = [1, 2, 3, 4, 5, 6, 7]

    @timetable = Timetable.find(params[:timetableID])
    @ttcells = @timetable.ttcells
  end


  # 시간표 삭제
  def delete
    @timetable = current_user.timetables.find(params[:timetableID])
    @timetable.delete
    redirect_to '/timetable'
  end

  # 대표 시간표 설정
  def main
    allTimetables = current_user.timetables
    allTimetables.each do |t|
      t.update_attributes(main: false) if t.main == true
    end

    timetable = current_user.timetables.find(params[:timetableID])
    timetable.update_attributes(main: true)

    redirect_to "/timetable"
  end



  private

  # 자신의 시간표인지 체크
  def checkMyTimetable
    @timetable = Timetable.find(params[:timetableID])
    redirect_to "/timetable" unless @timetable.user == current_user
  end


end
