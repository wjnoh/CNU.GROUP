# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


# 모든 단과대를 seed로 저장
    collegeList = College.create([{collegeName: "경E"},{collegeName: "경N"},{collegeName: "경S"},{collegeName: "공1"}, {collegeName: "공2"}, {collegeName: "공3"},
                    {collegeName: "공4"}, {collegeName: "공5"}, {collegeName: "교"}, {collegeName: "글로벌"}, {collegeName: "기1"}, {collegeName: "기2"},
                    {collegeName: "농1"}, {collegeName: "농2"}, {collegeName: "농3"}, {collegeName: "다2"} , {collegeName: "동물"}, {collegeName: "미"},
                    {collegeName: "사강"},{collegeName: "사범"},{collegeName: "사"},{collegeName: "산학연"},{collegeName: "수"},{collegeName: "생명"}, {collegeName: "생"},
                    {collegeName: "약"},{collegeName: "예디자"},{collegeName: "음1"},{collegeName: "음2"},{collegeName: "인"},{collegeName: "자1"},{collegeName: "자2"}])
    # 엑셀파일 중 강의시간 column을 불러와서 요일,시간,강의실로 token을 만든다.
    # 강의실은 위의 단과대(collegeList)에 저장하고, 요일,시간은 강의실에 저장되는 작업을 수행한다.


    xlsx = Roo::Spreadsheet.open('public/CNUclassroom.xlsx').column(1) - [" ", nil]

    # 배열 xlsx를 하나의 문자열로 만들어서 변수 stringOfXlsx 담는 loop
    for i in xlsx.length.downto(0)
      stringOfXlsx = xlsx[i].to_s + "+#{stringOfXlsx}"
    end

#1>
    # stringOfXlsx 존재하는 ,를 delimeter로 해서 공백,nil 등이 없는 완전한 문자열(perfectString)을 생성한다.
    # 그리고 나서 +를 token 단위로 tokenize를 실행하여 perfectString을 배열로 만든다.
    stringOfXlsx = stringOfXlsx.split(",")
    for i in stringOfXlsx.length.downto(0)
      perfectString = stringOfXlsx[i].to_s + "+#{perfectString}"
    end
    perfectString = perfectString.delete(" ").split("+")

#2>
    # 배열 perfectString의 원소들을 탐색해서 단과대별로 분류하여 배열로 만든다.
    classOfColleges = []

    for i in 0..collegeList.length-1   # 단과대별로 저장해야 하므로 바깥 loop는 collegeList 길이를 기준으로 한다.
      for j in 0..perfectString.length-1
        if perfectString[j].include?("#{collegeList[i].collegeName}")
          ##### 예외처리
          # 단과대가 "사"/"사강"/"사범"  "생"/"생명"인 경우 중복저장이 되므로 이를 처리해주어야 한다.
          if "#{collegeList[i].collegeName}" == "사" || "#{collegeList[i].collegeName}" == "생" || "#{collegeList[i].collegeName}" == "인" || "#{collegeList[i].collegeName}" == "공2"
            if perfectString[j].include?("사강") || perfectString[j].include?("사범") || perfectString[j].include?("생명") || perfectString[j].include?("인성관") || perfectString[j].include?("임산공")
              next
            end
          end

          # 단과대가 "수"인 경우, perfectString에서 요일이 수요일인 경우는 제외해야 한다.
          if "#{collegeList[i].collegeName}" == "수"
            if perfectString[j][0] == "수"
              next
            end
          end
          ######

          classOfColleges[i] = perfectString[j].to_s + "+#{classOfColleges[i]}"
        end
      end

      classOfColleges[i] = classOfColleges[i].split("+")
    end

#3>
    # 정규식을 이용하여 ((요일+시간) | 강의실)로 token을 나누고 이들이 한 묶음으로 유지될 수 있게 tokenize 작업을 수행한다.
    tokenStrings = []
    for i in 0..classOfColleges.length-1
      for j in (classOfColleges[i].length-1).downto(0)
        # (강의실)과 같은 형식으로 되어 있으므로 ( 와 )를 토큰으로해서 문자열을 tokenize한다.
        classOfColleges[i][j] = classOfColleges[i][j].split(/\(|\)/) - [""]
        tokenStrings[i] = classOfColleges[i][j].to_s + "+#{tokenStrings[i]}"
      end
      tokenStrings[i] = tokenStrings[i].split("+")
    end

#4-1>
    # tokenStrings 각 배열의 원소마다 요일, 시간의 글자수가 같은 점을 이용하여 강의실만 뽑아낸다.
    # allClassList는 중복을 포함한 모든 강의실을 저장하는 배열이다. (classTime과 대응시키기 위해 사용됨)
    classList = []
    allClassList = []
    m = 0
    for i in 0..tokenStrings.length-1
      for j in (tokenStrings[i].length-1).downto(0)
        for k in (tokenStrings[i][j].length-3).downto(18)
          classList[m] = tokenStrings[i][j][k] + "#{classList[m]}"
        end
        allClassList[m] = classList[m]
      end
      m = m + 1
    end

#4-2>
    # 강의실 중복제거를 위해 uniq 메서드를 사용하는데, 그러기 위해서는 배열로 만들 필요가 있다.
    for i in 0..classList.length-1
      for j in 0..collegeList.length-1
        if classList[i].include?("#{collegeList[j].collegeName}")
          allClassList[i] = allClassList[i].split(/#{collegeList[j].collegeName}/) - [""]
          classList[i] = classList[i].split(/#{collegeList[j].collegeName}/).uniq - [""]

          # classList 각 원소마다 단과대 건물이름이 포함되야 하므로 단과대 이름을 추가해준다.
          for k in 0..(classList[i].length-1)
            classList[i][k] = "#{collegeList[j].collegeName}" + classList[i][k].to_s
          end

          for k in 0..allClassList[i].length-1
            allClassList[i][k] = "#{collegeList[j].collegeName}" + allClassList[i][k].to_s
          end

        end
      end
    end

#5-1>
    # tokenStrings 각 배열의 원소에서 요일과 시간을 한 묶음으로 뽑아낸다.
    timeList = []
    m = 0
    for i in 0..tokenStrings.length-1
      for j in (tokenStrings[i].length-1).downto(0)
        for k in 13.downto(2)
          timeList[m] = tokenStrings[i][j][k] + "#{timeList[m]}"
        end
      end
      timeList[m] = timeList[m].split(/([월|화|수|목|금|토])/) - [""]
      m = m+1
    end

#5-2>
    # 요일을 기준으로 토큰을 나누었기 때문에 요일과 시간이 합쳐지려면 timeList의 각 인덱스를
    # [0,1] [2,3] [4,5] ...와 같이 합쳐야 한다. loop의 증가는 0 2 4 ..
    for i in 0..timeList.length-1
      for j in (0..timeList[i].length-2).step(2)
        timeList[i][j] = timeList[i][j] + timeList[i][j+1]
      end
    end

    #(최종) 홀수 번째의 index에 대해서는 데이터가 그대로 남아 있기 때문에 공백으로 만든 뒤에
    # 공백을 제거해서 요일과 시간만 남도록 한다.
    for i in (0..timeList.length-1)
      for j in (1..timeList[i].length-1).step(2)
        timeList[i][j] = ""
      end
      timeList[i].delete("")
    end


# collegeList : 단과대 목록
# allClassList : 중복이 허용된 강의실   <=>   timeList : 요일과 시간이 같이 있는 시간표
# classList : 중복을 허용하지 않은 강의실

############### 강의실이 포함된 단과대에 맞게 seed에 저장
    for i in 0..collegeList.length-1
      for j in 0..classList[i].length-1
        classRoom = ClassRoom.create({classRoomName: classList[i][j], college: collegeList[i]})
      end
    end


############### 강의실에 포함된 시간과 요일을 seed에 저장
    # DB에는 중복되지 않은 강의실이 저장되어 있지만 시간표는 중복된 강의실이 필요하다.
    # 그래서 사용되는 것이 allClassList 배열이다.
    for i in 0..classList.length-1
      for j in 0..timeList[i].length-1
        for k in 0..classList[i].length-1
          # 중복되지 않은 강의실이 저장된 배열 classList와 같은 문자열을 갖는 allClassList의 한 원소를 찾으면
          # DB에 추가하는데 이 때 timeList[i][j] 와 allClassList[i][j]는 서로 대응된다는 점을 이용한다.
          if allClassList[i][j] == classList[i][k]
            # 시간표는 강의실에 belongs_to되므로 query문으로 강의실이 같은 것을 탐색하도록 한다.
            elementOfClassList = ClassRoom.where(classRoomName: classList[i][k]).take

            classTime = ClassTime.create(
              {dayAndTimeInterval: timeList[i][j], classRoom: elementOfClassList}
            )
            break
          end

        end
      end
    end

############# timeList의 각 원소를 요일과 시간으로 분리해서 seed에 저장
    # timeList의 원소를 요일과 시간으로 나눠서 seed에 저장하는 것이 전부이므로
    # timeList에 저장된 id 순으로 요일과 시간을 분리해서 각각 저장하면 된다.
    # 이때 timeList 모델과 DayAndTimeOfClass 모델은 1:1 관계이다.
    m = 1
    for i in 0..timeList.length-1
      for j in 0..timeList[i].length-1
        dayAndTime = timeList[i][j]
        day = dayAndTime[0]
        time = dayAndTime[1..dayAndTime.length-1]

        elementOfTimeList = ClassTime.find(m)
        DayAndTimeOfClass.create({day: day, time: time, classTime: elementOfTimeList})
        m = m + 1
      end
    end
