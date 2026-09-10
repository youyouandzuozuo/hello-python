#TempConvert_v3.py
TempStr = input("请输入带有符号的温度;（如321K，321C）")
if TempStr[-1] in ['K','k']:
    C = eval(TempStr[0:-1]) - 273.15
    print("转换后的温度为{:.2f}C".format(C))
elif TempStr[-1] in ['c','C']:
    K = eval(TempStr[0:-1]) +  273.15
    print("转换后的温度为{:.2f}K".format(K))
else:
    print("输入格式错误")