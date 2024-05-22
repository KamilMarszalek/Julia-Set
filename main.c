#include <stdio.h>
#include <stdlib.h>
#include <allegro5/allegro.h>
#include <allegro5/allegro_font.h>
#include "juliaSet.h"

#define WIDTH 800
#define HEIGHT 800

void displayRGB(unsigned* pixels, int width, int height){
    for (int row = 0; row < height; row++){
        for (int col = 0; col < width; col++){
            int pixelIndex = 3*(row*width + col);
            al_draw_pixel(col, row, al_map_rgb(
                pixels[pixelIndex],
                pixels[pixelIndex + 1],
                pixels[pixelIndex + 2]
            ));
        }
    }
}

int main(){
    al_init();
    al_install_keyboard();
    ALLEGRO_EVENT_QUEUE* event_queue = al_create_event_queue();
    ALLEGRO_TIMER* timer = al_create_timer(1.0/60.0);
    ALLEGRO_DISPLAY* display = al_create_display(WIDTH, HEIGHT);
    unsigned* pixels = (unsigned*)malloc(WIDTH*HEIGHT*3);
    double offsetX = (double)WIDTH/2;
    double offsetY = (double)HEIGHT/2;
    double scale = 1.0;

    al_register_event_source(event_queue, al_get_keyboard_event_source());
    al_register_event_source(event_queue, al_get_timer_event_source(timer));

    ALLEGRO_EVENT event;

    double cReal = -0.7;
    double cImag = 0.27015;
    double escapeRadius = 2.0;

    juliaSet(pixels, WIDTH, HEIGHT, escapeRadius, cReal, cImag, offsetX, offsetY, scale);
    displayRGB(pixels, WIDTH, HEIGHT);
    while(true);
    return 0;

}

