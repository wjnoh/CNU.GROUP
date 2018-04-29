class ClassroomController < ApplicationController

  $previousCollegeId      # 최근에 선택한 단과대의    id를 저장하는 전역변수
  $previousDayValue       # 최근에 선택한 요일의   value를 저장하는 전역변수
  $previousClassRoomValue # 최근에 선택한 강의실의 value를 저장하는 전역변수


  def search
    # 뷰 페이지의 select 속성의 option 처리
    selectOptionModule

    # hashClassAndTimes         -    key : 강의실 , value : 해당 요일의 시간표들
    createHashClassAndTimes

    # hashCheckClassAndTimes    -    key : (수업중)을 명시한 강의실 , value :  해당 요일의 시간표들
    createHashCheckClassAndTimes


    # 해당 요일의 수업이 아예 없는 경우 뷰페이지에서 출력하기 위한 value들의 집합
    @valuesHashCheckClassAndTimes = @hashCheckClassAndTimes.values
    @valuesHashCheckClassAndTimes.each do |value|
      value = value.delete("") if  value.empty?
    end
    @valuesHashCheckClassAndTimes = @valuesHashCheckClassAndTimes - [nil]


    # 현재 시간을 기준으로 다음 수업까지 얼마나 남았는지 계산,
    # hashClassAndRemainTime   -   key : 강의실 , value : 다음수업까지 남은시간
    remainTime

  end



  private

  # 뷰 페이지의 select 속성의 option을 처리하는 모듈
  def selectOptionModule
    @currentCollegeValue = params[:college]
    @currentDayValue = params[:day]
    @currentClassRoomValue = params[:theClass]

    # 처음 로딩되었을 때 오늘 날짜가 선택 되도록 한다.
    dayOfToday = Time.now.strftime("%a")
    case dayOfToday
      when "Mon"
        dayOfToday = "월요일"
      when "Tue"
         dayOfToday = "화요일"
      when "Wed"
        dayOfToday = "수요일"
      when "Thu"
        dayOfToday = "목요일"
      when "Fri"
        dayOfToday = "금요일"
      when "Sat"
        dayOfToday = "토요일"
      when "Sun"
        dayOfToday = "월요일"
    end

    # 처음 로딩 시 초기 값 설정
    if @currentCollegeValue.nil? && @currentDayValue.nil? && @currentClassRoomValue.nil?
      $previousCollegeId = 1
      @currentDayValue = dayOfToday
      $previousClassRoomValue = "빈 강의실"
    end

    # 단과대를 바꿨을 때
    if @currentDayValue.nil? && @currentClassRoomValue.nil?
      @college = College.find_by(collegeName: @currentCollegeValue)
      $previousCollegeId = @college.id

      @currentDayValue = $previousDayValue
      @currentClassRoomValue = "빈 강의실"    # 빈 강의실이 기본 값
    end

    # 요일을 바꿨을 때
    if @currentCollegeValue.nil? && @currentClassRoomValue.nil?
      $previousDayValue = @currentDayValue

      @currentClassRoomValue = $previousClassRoomValue
      @college = College.find($previousCollegeId)
      @currentCollegeValue = @college.collegeName
    end

    # 강의실을 바꿨을 때
    if @currentDayValue.nil? && @currentCollegeValue.nil?
      $previousClassRoomValue = @currentClassRoomValue

      @currentDayValue = $previousDayValue
      @college = College.find($previousCollegeId)
      @currentCollegeValue = @college.collegeName
    end
  end



  # hashClassAndTimes 생성 모듈
  def createHashClassAndTimes
    @classRooms = ClassRoom.where(college_id: @college.id).order(:classRoomName)    # 해당 단과대의 강의실 목록
    classTimes = []           # 각 강의실의 시간표 목록을 담는 배열
    @classTimesOfDay = []     # 사용자가 선택한 요일의 시간표들을 담는 배열

    for i in 0..@classRooms.length-1
      tempClassTimesOfDay = []
      classTimes[i] = ClassTime.where(classRoom_id: @classRooms[i].id)

      for j in 0..classTimes[i].length-1
        classDayAndTimes = DayAndTimeOfClass.find_by(classTime_id: classTimes[i][j].id)
        if classDayAndTimes.day == @currentDayValue.slice(0)
          tempClassTimesOfDay[j] = classDayAndTimes.time
        end
      end

      @classTimesOfDay.push(tempClassTimesOfDay)
      @classTimesOfDay[i] = (@classTimesOfDay[i] -[nil]).sort
    end

    @hashClassAndTimes = Hash.new
    for i in 0..@classTimesOfDay.length-1
      @hashClassAndTimes.store("#{@classRooms[i].classRoomName}", @classTimesOfDay[i])
    end
  end



  # hashCheckClassAndTimes 생성 모듈
  def createHashCheckClassAndTimes
    @currentTime = Time.now.strftime("%H:%M")       # 현재 시간 (시,분)
    emptyCheckClassRooms = []

    for i in 0..@classTimesOfDay.length-1
      emptyCheckClassRooms[i] = @classRooms[i].classRoomName

      for j in 0..@classTimesOfDay[i].length-1
        if @currentTime < @classTimesOfDay[i][j].slice(6..@classTimesOfDay[i][j].length-1)    # 현재시간과 수업이 끝나는 시간을 비교
          if @currentTime > @classTimesOfDay[i][j].slice(0..4)                                # 그 수업시간의 시작시간과 현재시간을 비교
            emptyCheckClassRooms[i] = @classRooms[i].classRoomName + " (수업중)"
            break
          end
        end
      end
    end

    @hashCheckClassAndTimes = Hash.new
    for i in 0..emptyCheckClassRooms.length-1
      @hashCheckClassAndTimes.store("#{emptyCheckClassRooms[i]}", @classTimesOfDay[i])
    end
  end



  # 다음 수업까지 얼마나 남았는지 처리하는 모듈
  def remainTime
    @diffTime = []
    for i in 0..@classTimesOfDay.length-1
      for j in 0..@classTimesOfDay[i].length-1
        startClassTime = @classTimesOfDay[i][j].slice(0..4)
        endClassTime = @classTimesOfDay[i][j].slice(6..10)

        if @currentTime < startClassTime                     # 강의 시작시간과 현재 시간을 비교한다.
          hourCurrentTime = @currentTime.slice(0..1).to_i
          minCurrentTime = @currentTime.slice(3..4).to_i
          totalMinCurrentTime = hourCurrentTime*60 + minCurrentTime

          hourClassTime = startClassTime.slice(0..1).to_i
          minClassTime = startClassTime.slice(3..4).to_i
          totalMinClassTime = hourClassTime*60 + minClassTime

          calculateDiffCurrentFromClass = totalMinClassTime - totalMinCurrentTime
          hourDiffCurrentFromClass = calculateDiffCurrentFromClass / 60
          minDiffCurrentFromClass = calculateDiffCurrentFromClass % 60

          # 최종적으로 해쉬의 value값으로 저장할 배열
          @diffTime[i] = [hourDiffCurrentFromClass , minDiffCurrentFromClass]

          break

        else
          # 현재 시간 앞으로 수업이 비어있을 경우 nil로 저장하여 뷰 페이지에서 "이후의 수업이 없다"를 출력할 것이다.
          @diffTime[i] = nil
        end
      end
    end

    # 이 해쉬는 hashCheckClassAndTimes 해쉬와 같은 키 값을 갖고 있다.
    @hashClassAndRemainTime = Hash.new
    for i in 0..@classRooms.length-1
      @hashClassAndRemainTime.store("#{@classRooms[i].classRoomName}", @diffTime[i])
    end
  end


end
