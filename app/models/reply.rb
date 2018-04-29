class Reply < ApplicationRecord
  # 1:N 관계인 column은 blank가 될 수 없다. 그러나 1:N관계인 모든 column를 가질 필요는 없다.
  # 따라서 선택적으로 필요한 1:N관계인 column을 갖을 수 있도록 하기 위해서는 optional을 이용한다.
  # 즉 blank를 허용한다.
  belongs_to :post            , optional: true
  belongs_to :freepost        , optional: true
  belongs_to :adpost          , optional: true
  belongs_to :suggestionpost  , optional: true
  belongs_to :user

end
