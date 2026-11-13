#include "gt/gametank.h"
#include "gt/gfx/draw_queue.h"

#include "gt/banking.h"
#include "gt/gfx/draw_direct.h"
#include "gen/assets/font.h"


char box_x = 30, box_y = 20;
char dx = 1, dy = 1;

const unsigned char tilemap[256] = {
  3, 0x53, 1, 6, 4, 3, 2, 1, 3, 3, 3, 3, 3, 3, 3, 3,
  3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
  3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
  3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
  3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
  3, 3, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3,
  3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
  3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
  3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
  3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
  3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
  3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
  3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
  3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
  3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
  3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
};


void soft_draw_tilemap();

void main () {
  change_rom_bank(ASSET__font__bios8_bmp_bank);
  direct_prepare_sprite_ram_array_mode(0);

  PROFILER_START(0);
  soft_draw_tilemap();
  PROFILER_END(0);

  // text_load_font(0);

    // Run forever
    while (1) {
        queue_clear_screen(3);
        queue_draw_box(box_x, box_y, 8, 8, 92);
        queue_clear_border(0);

        box_x += dx;
        box_y += dy;
        if(box_x == 1) {
            dx = 1;
        } else if(box_x == 119) {
            dx = -1;
        }
        if(box_y == 8) {
            dy = 1;
        } else if(box_y == 112) {
            dy = -1;
        }

        await_draw_queue();
        await_vsync(1);
        flip_pages();

    }
}
