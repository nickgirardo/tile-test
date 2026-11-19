#include "gt/gametank.h"
#include "gt/gfx/draw_queue.h"

#include "gt/banking.h"
#include "gt/gfx/draw_direct.h"

#include "gen/assets/overworld.h"
#include "gen/assets/leveldata.h"

void soft_draw_tilemap();
void __fastcall__ copy_aligned_page(unsigned char *dst, const unsigned char *src);

char box_x = 30, box_y = 20;
char dx = 1, dy = 1;

// Basic camera controls
char cam_scroll = 0;
char cam_page = 0;
char cam_scroll_stop_page = 0;

// This section is forced to be page-aligned by the linker
#pragma bss-name(push, "TILEMAP")
unsigned char tilemap[256];
#pragma bss-name(pop)

void main () {
  char num_pages;
  char i;

  change_rom_bank(ASSET__leveldata__grass_leveldata_bank);
  num_pages = ASSET__leveldata__grass_leveldata_ptr[0];
  cam_scroll_stop_page = num_pages - 1;

  for (i = 0; i < num_pages; i++) {
    change_rom_bank(ASSET__leveldata__grass_leveldata_bank);

    copy_aligned_page(tilemap,
           (const unsigned char *) ASSET__leveldata__grass_leveldata_ptr + 256 + (i * 256)
           );

    change_rom_bank(ASSET__overworld__tiles2_bmp_bank);
    direct_prepare_sprite_ram_array_mode(i);

    soft_draw_tilemap();
  }


  // Run forever
  while (1) {
    queue_draw_img(cam_page, 0, 0, 127 - cam_scroll, 127, cam_scroll, 0);
    if (cam_scroll != 0) {
      queue_draw_img(cam_page + 1, 127 - cam_scroll, 0, cam_scroll, 127, 0, 0);
    }

    if (cam_page != cam_scroll_stop_page) {
      cam_scroll++;
      if (cam_scroll == 128) {
        cam_scroll = 0;
        cam_page++;
      }
    }

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
