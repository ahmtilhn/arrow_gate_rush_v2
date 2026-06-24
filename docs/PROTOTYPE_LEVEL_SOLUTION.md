# Phase 2 Prototype Level Solution

The deterministic 6x6 tick-zero solution is:

1. `g_right`
2. `g_blocked`
3. `b_up`
4. `r_left`
5. `y_down`
6. `r_down`

`g_blocked` must leave before `y_down` because it occupies column 0. The earlier documented order was invalid. The board and gate lanes are recreated deterministically on restart.
