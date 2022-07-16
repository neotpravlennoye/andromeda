local _, C = unpack(select(2, ...))

C.NameplateAuraWhiteList = {
    -- Buffs
    [642] = true, -- 圣盾术
    [1022] = true, -- 保护之手
    [23920] = true, -- 法术反射
    [45438] = true, -- 寒冰屏障
    [186265] = true, -- 灵龟守护

    -- Debuffs
    [2094] = true, -- 致盲
    [10326] = true, -- 超度邪恶
    [20549] = true, -- 战争践踏
    [107079] = true, -- 震山掌
    [117405] = true, -- 束缚射击
    [127797] = true, -- 乌索尔旋风
    [272295] = true, -- 悬赏

    -- Mythic+
    [228318] = true, -- 激怒
    [226510] = true, -- 血池
    [343553] = true, -- 万噬之怨
    [343502] = true, -- 鼓舞光环

    -- Dungeons
    [320293] = true, -- 伤逝剧场，融入死亡
    [331510] = true, -- 伤逝剧场，死亡之愿
    [333241] = true, -- 伤逝剧场，暴脾气
    [336449] = true, -- 凋魂之殇，玛卓克萨斯之墓
    [336451] = true, -- 凋魂之殇，玛卓克萨斯之壁
    [333737] = true, -- 凋魂之殇，凝结之疾
    [328175] = true, -- 凋魂之殇，凝结之疾
    [340357] = true, -- 凋魂之殇，急速感染
    [228626] = true, -- 彼界，怨灵之瓮
    [344739] = true, -- 彼界，幽灵
    [333227] = true, -- 彼界，不死之怒
    [326450] = true, -- 赎罪大厅，忠心的野兽
    [343558] = true, -- 通灵战潮，病态凝视
    [343470] = true, -- 通灵战潮，碎骨之盾
    [328351] = true, -- 通灵战潮，染血长枪
    [322433] = true, -- 赤红深渊，石肤术
    [321402] = true, -- 赤红深渊，饱餐
    [327416] = true, -- 晋升高塔，心能回灌
    [317936] = true, -- 晋升高塔，弃誓信条
    [327812] = true, -- 晋升高塔，振奋英气
    [339917] = true, -- 晋升高塔，命运之矛
    [323149] = true, -- 仙林，黑暗之拥
    [322569] = true, -- 仙林，兹洛斯之手
    [355147] = true, -- 集市，鱼群鼓舞
    [355057] = true, -- 集市，鱼人战吼
    [351088] = true, -- 集市，圣物联结
    [355640] = true, -- 集市，重装方阵
    [355783] = true, -- 集市，力量增幅
    [347840] = true, -- 集市，野性
    [347015] = true, -- 集市，强化防御
    [355934] = true, -- 集市，强光屏障
    [349933] = true, -- 集市，狂热鞭笞协议
    [350931] = true, -- 爬塔软泥免疫
    [164504] = true, -- 钢铁码头，威吓

    -- S3, Encrypted
    [368078] = true, -- 飘移力场
    [368103] = true, -- 加速力场
    [368243] = true, -- 能量弹幕

    -- Raids
    [334695] = true, -- 动荡能量，猎手
    [345902] = true, -- 破裂的联结，猎手
    [346792] = true, -- 罪触之刃，猩红议会
}

C.NameplateAuraBlackList = {
    [15407] = true, -- 精神鞭笞
    [51714] = true, -- 锋锐之霜
    [199721] = true, -- 腐烂光环
    [214968] = true, -- 死灵光环
    [214975] = true, -- 抑心光环
    [273977] = true, -- 亡者之握
    [276919] = true, -- 承受压力
    [206930] = true, -- 心脏打击
}

-- 显示姓名板单位的目标
C.NameplateShowTargetNPCsList = {
    [165251] = true, -- 仙林狐狸
    [174773] = true, -- 怨毒怪
}

-- 无效目标
C.TrashUnitsList = {
    [166589] = true, -- 活化武器，赤红
    [169753] = true, -- 饥饿的虱子，赤红
    [175677] = true, -- 走私来的生物，集市
}

C.SpecialUnitsList = {
    [179823] = true, -- 圣物收集者，刻希亚
    [179565] = true, -- 圣物饕餮者，刻希亚
    [180501] = true, -- 无辜的灵魂，低语威能碎片
    -- Dungeons
    [120651] = true, -- 大米，爆炸物
    [174773] = true, -- 大米，怨毒影魔
    [184908] = true, -- 大米，维型拆解者
    [184910] = true, -- 大米，沃型拆解者
    [184911] = true, -- 大米，尤型拆解者
    [169498] = true, -- 凋魂之殇，魔药炸弹
    [170851] = true, -- 凋魂之殇，易爆魔药炸弹
    [165556] = true, -- 赤红深渊，瞬息具象
    [170234] = true, -- 伤逝剧场，压制战旗
    [164464] = true, -- 伤逝剧场，卑劣的席拉
    [165251] = true, -- 仙林，幻影仙狐
    [171341] = true, -- 彼界，幼鹤
    [175576] = true, -- 集市，监禁
    [179733] = true, -- 集市，鱼串
    [180433] = true, -- 集市，流浪的脉冲星
    [104251] = true, -- 群星庭院，哨兵
    [101008] = true, -- 黑鸦堡垒，针刺虫群
    -- Raids
    [175992] = true, -- 猩红议会，忠实的侍从
    [165762] = true, -- 凯子，灵能灌注者
    -- Condemned Demon
    [169430] = true,
    [169428] = true,
    [168932] = true,
    [169425] = true,
    [169429] = true,
    [169421] = true,
    [169426] = true,
}

C.PowerUnitsList = {
    [165556] = true, -- 赤红深渊，瞬息具象
    [171557] = true, -- 猎手阿尔迪莫，巴加斯特之影
}

C.MajorSpellsList = {
    [358967] = true, -- S2，地狱烈火
    [334664] = true, -- 彼界，惊恐嚎哭
    [332612] = true, -- 彼界，治疗波
    [332706] = true, -- 彼界，治疗
    [334051] = true, -- 彼界，喷涌黑暗
    [332084] = true, -- 彼界，自清洁循环
    [321828] = true, -- 仙林，肉饼蛋糕
    [326046] = true, -- 仙林，模拟抗性
    [326450] = true, -- 赎罪大厅，忠心的野兽
    [325700] = true, -- 赎罪大厅，收集罪恶
    [323552] = true, -- 赎罪大厅，能量箭雨
    [341969] = true, -- 伤势剧场，凋零释放
    [330586] = true, -- 伤势剧场，吞噬血肉
    [333294] = true, -- 伤势剧场，死亡之风
    [330868] = true, -- 伤势剧场，通灵箭雨
    [327413] = true, -- 晋升高塔，反抗之拳
    [317936] = true, -- 晋升高塔，弃誓信条
    [324293] = true, -- 通灵战潮，刺耳尖啸
    [334748] = true, -- 通灵战潮，排干体液
    [334749] = true, -- 通灵战潮，排干体液
    [338357] = true, -- 通灵战潮，暴捶
    [320596] = true, -- 通灵战潮，深重呕吐
    [326827] = true, -- 赤红深渊，恐惧之缚
    [326831] = true, -- 赤红深渊，恐惧之缚
    [327233] = true, -- 凋魂，喷射魔药
    [324667] = true, -- 凋魂，软泥浪潮
    [328400] = true, -- 凋魂，潜行幼蛛
    [351119] = true, -- 集市，闪击手里剑
    [356031] = true, -- 集市，静滞射线
    [357226] = true, -- 集市，游移之星
    [357284] = true, -- 集市，重唤活力
    [357260] = true, -- 集市，不稳定的裂隙
    [355132] = true, -- 集市，活力鱼串
    [355057] = true, -- 集市，鱼人战吼
    [355234] = true, -- 集市，不稳定的河豚
    [355642] = true, -- 集市，凌光齐射
    [356407] = true, -- 集市，上古恐慌
    [347721] = true, -- 集市，打开牢笼
    [353783] = true, -- 集市，传送
}
