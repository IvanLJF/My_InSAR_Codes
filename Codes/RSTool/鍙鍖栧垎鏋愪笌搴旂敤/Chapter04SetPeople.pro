; Chapter04SetPeople.pro
PRO  Chapter04SetPeople
　　COMMON SetPeopleInformation, MyName, MyAge, MySex, MyTime
　　MyName =' '
　　MyAge = 0B
　　MySex =' '
　　READ,  PROMPT = "请输入姓名：", MyName
　　READ,  PROMPT = "请输入年龄：", MyAge
　　READ,  PROMPT = "请输入性别（Male 或 Female）：", MySex
　　MyTime = SYSTIME()
END