#TempConvert_v2.py
TempStr = input("请输入带符号的温度值（例如：32C，99F）：")
if TempStr[-1] in ['F','f']:
    C = (eval(TempStr[0:-1])-32)/1.8
    print("转换后的温度是{:.2f}C".format(C))
elif TempStr[-1] in ['C','c']:
    F = eval(TempStr[0:-1])*1.8+32
    print("转换后的温度是{:.2f}F".format(F))
else:
    print("输入格式错误")