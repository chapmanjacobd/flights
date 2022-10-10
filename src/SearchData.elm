module SearchData exposing (Search, searchData)


type alias Search =
    { id : Int
    , name : String
    , displayname : String
    }


searchData : List Search
searchData =
    [ Search 1 "Mexico CityDistrito FederalMX[ Mexico City    Ciudad de M    Mexiko-Stadt    Ciudad de México    Mexico    Ciudad de México    Мехико    墨西哥城    مدينة مكسيكو    মেক্সিকো সিটি    Πόλη του Μεξικού    मेक्सिको नगर    Mexikóváros    Kota Meksiko    Città del Messico    メキシコシティ    멕시코시티    Mexico-Stad    Meksyk    Mexico City    Meksiko    Thành phố México ][ TLC    MEX ][ MMCB    MMMX    MMPB    MMQT    MMTO    MMJC ]" "Mexico City (Distrito Federal MX)"
    , Search 2 "MumbaiMaharashtraIN[ Mumbai    Bombay    Mumbai    Bombay    Bombay    Bombaim    Мумбаи    孟买    مومباي    মুম্বই    Μουμπάι    मुम्बई    Mumbai    Mumbai    Mumbai    ムンバイ    뭄바이    Bombay    Mumbaj    Bombay    Mumbai    Mumbai ][ DIU    PNQ    BOM ][ VABB    VAOZ    VAPO    VASD    VASU    VAJJ ]" "Mumbai (Maharashtra IN)"
    , Search 3 "Sao PauloSão PauloBR[ São Paulo    Sao Paulo|Sio Paulo    São Paulo    São Paulo    São Paulo    São Paulo    Сан-Паулу    聖保羅    ساو باولو    সাও পাওলো    Σάο Πάολο    साओ पाउलो    São Paulo    São Paulo    San Paolo    サンパウロ    상파울루    São Paulo    São Paulo    São Paulo    São Paulo    São Paulo ][ SOD    VCP    CGH ][ SBGR    SBKP    SBSJ    SBSP    SBMT    SDNI    SDTB ]" "Sao Paulo (São Paulo BR)"
    , Search 4 "ShanghaiShanghaiCN[ Shanghai    Shanghai    Shanghái    Shanghai    Xangai    Шанхай    上海    شانغهاي    সাংহাই    Σαγκάη    शंघाई    Sanghaj    Shanghai    Shanghai    上海市    상하이 시    Shanghai    Szanghaj    Shanghai    Şanghay    Thượng Hải ][ NTG    WUX    SHA ][ ZSHC    ZSNB    ZSPD    ZSSS    ZSWX ]" "Shanghai (Shanghai CN)"
    , Search 5 "Buenos AiresCiudad de Buenos AiresAR[ Buenos Aires    Buenos Aires    Buenos Aires    Buenos Aires    Buenos Aires    Буэнос-Айрес    布宜諾斯艾利斯    بوينس آيرس    বুয়েনোস আইরেস    Μπουένος Άιρες    ब्यूनस आयर्स    Buenos Aires    Buenos Aires    Buenos Aires    ブエノスアイレス    부에노스아이레스    Buenos Aires    Buenos Aires    Buenos Aires    Buenos Aires    Buenos Aires ][ AEP    EZE ][ SABE    SAEZ    SABE    SADQ    SADZ ]" "Buenos Aires (Ciudad de Buenos Aires AR)"
    , Search 6 "KarachiSindPK[ Karachi    Karatschi    Karachi    Karachi    Carachi    Карачи    卡拉奇    كراتشي    করাচী    Καράτσι    कराची    Karacsi    Karachi    Karachi    カラチ    카라치    Karachi    Karaczi    Karachi    Karaçi    Karachi ][ HDD    KHI ][ OPKC    OPNH    OPSN    OPKK    OPMR    OPSF ]" "Karachi (Sind PK)"
    , Search 7 "MoscowMoskvaRU[ Moscow    Moskva    Moskau    Moscú    Moscou    Moscovo    Москва    莫斯科    موسكو    মস্কো    Μόσχα    मास्को    Moszkva    Moskwa    Mosca    モスクワ    모스크바    Moskou    Moskwa    Moskva    Moskova    Moskva ][ OSF    SVO ][ UUBW    UUDD    UUEE    UUMO    UUWW    UUBM    UUMO ]" "Moscow (Moskva RU)"
    , Search 8 "TokyoTokyoJP[ Tokyo    Präfektur Tokio    Tokio    Tokyo    Tóquio    Токио    東京都    طوكيو    টোকিও    Τόκιο    टोक्यो    Tokió    Tokyo    Tokyo    東京都    도쿄도    Tokio    Tokio    Tokyo prefektur    Tokyo    Tokyo ][ IBR    HND ][ RJAA    RJAH    RJTF    RJTO    RJTT    RJTF    RJTK    RJTL ]" "Tokyo (Tokyo JP)"
    , Search 9 "New YorkNew YorkUS[ New York    New York-Newark    New York City    Nueva York    New York    Nova Iorque    Нью-Йорк    纽约    نيويورك    নিউ ইয়র্ক সিটি    Νέα Υόρκη    न्यूयॉर्क नगर    New York    New York City    New York    ニューヨーク    뉴욕    New York City    Nowy Jork    New York    New York    Thành phố New York ][ WST    HPN    LGA ][ KEWR    KHPN    KJFK    KLGA    KSWF    KCDW    KLDJ    KTEB ]" "New York (New York US)"
    , Search 10 "DelhiDelhiIN[ Delhi    Delhi    Delhi    Delhi    Deli    Дели    德里    دلهي    দিল্লি    Δελχί    दिल्ली    Delhi    Delhi    Delhi    デリー    델리    Delhi    Delhi    Delhi    Delhi    Delhi ][ AIP    DED    DEL ][ VICG    VIDN    VIDP    VA2B    VIDD    VIDX ]" "Delhi (Delhi IN)"
    ]
