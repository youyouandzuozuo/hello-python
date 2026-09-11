#TempConvert_v5.py —— 周末自查：空白文件脱稿重敲（教材原版 F<->C）
#刻意保留 eval（与教材一致）；我已知道正经写法是 float()，见 TempConvert_v4.py
TempStr = input("Please enter temperature with symbol:")
if TempStr[-1] in  ['F','f']:
    C = (eval(TempStr[0:-1])-32)/1.8
    print("Converted temperature:{:.2f}".format(C))
elif TempStr[-1] in ['C','c']:
    F = eval(TempStr[0:-1])*1.8+32
    print("Converted temperature:{:.2f}".format(F))
else:
    print("Format error")