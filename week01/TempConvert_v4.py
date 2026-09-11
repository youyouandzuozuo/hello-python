#TempConvert_v4(.4f/.2f 是故意的对比测试)
TempStr = input("请输入带符号的温度:")
if TempStr[-1] in ['k','K']:
    C = float(TempStr[0:-1]) - 273.15
    print("转换结果：{:.4f}C".format(C))
elif TempStr[-1] in ['c','C']:
    K = float(TempStr[0:-1]) + 273.15
    print("转换结果:{:.2f}K".format(K))
else:
    print("你输错了")