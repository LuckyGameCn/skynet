
package.path = "./luckynet/lnlib/?.lua;" .. package.path
package.path = "./luckyproto/?.lua;" .. package.path

DPROTO_TYEP_OK = 0
DPROTO_TYEP_FAIL = -1

DPROTO_TYEP_LOGOUT = 1
DPROTO_TYEP_PUSH = 2

DPROTO_TYEP_LADDERIN = 100
DPROTO_TYEP_LADDERCON = 102

DPROTO_TYEP_LADDEROK = 103 --天梯全部确认完毕

DPROTO_TYEP_DATA_INIT = 10
DPROTO_TYEP_DATA = 11
DPROTO_TYEP_DATA_END = 12