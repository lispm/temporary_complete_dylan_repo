/* 
TEST_HEADER
 id = $HopeName$
 summary = UNALIGNED addr_t to mps_reserve
 language = c
 link = testlib.o newfmt.o
END_HEADER
*/

#include "testlib.h"
#include "mpscamc.h"
#include "newfmt.h"
#include "arg.h"

#undef mps_reserve
#undef mps_commit

void *stackpointer;

static void test(void)
{
 mps_space_t space;
 mps_pool_t pool;
 mps_thr_t thread;
 mps_root_t root;

 mps_fmt_t format;
 mps_ap_t ap;

 cdie(mps_space_create(&space), "create space");

 cdie(mps_thread_reg(&thread, space), "register thread");

 cdie(
  mps_root_create_reg(&root, space, MPS_RANK_AMBIG, 0, thread,
   mps_stack_scan_ambig, stackpointer, 0),
  "create root");

 cdie(
  mps_fmt_create_A(&format, space, &fmtA),
  "create format");

 formatcomments = 0;

 cdie(
  mps_pool_create(&pool, space, mps_class_amc(), format),
  "create pool");

 cdie(
  mps_ap_create(&ap, pool, MPS_RANK_EXACT),
  "create ap");

 cdie(
  mps_reserve(UNALIGNED, ap, (size_t) 32), "reserve");

}

int main(void)
{
 void *m;
 stackpointer=&m; /* hack to get stack pointer */

 easy_tramp(test);
 return 0;
}
