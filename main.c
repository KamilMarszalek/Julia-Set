#include <allegro5/allegro5.h>
#include "juliaSet.h"
#include "constants.h"
#include <stdio.h>


void restart_params(double *cReal, double *cImag, double *scale, double *offsetReal, double *offsetImag) {
    *cReal = START_C_REAL;
    *cImag = START_C_IMAG;
    *scale = START_SCALE;
    *offsetReal = (double)WIDTH / 2;
    *offsetImag = (double)HEIGHT / 2;
}

void displayRGBPixels(uint8_t pixels[], int width, int height) {
    for (int row = 0; row < height; row++) {
        for (int col = 0; col < width; col++) {
            int pixelIndex = 3 * (row * width + col);
            al_draw_pixel(col, row, al_map_rgb(pixels[pixelIndex], pixels[pixelIndex + 1],pixels[pixelIndex + 2]));
        }
    }
}

double max(double a, double b) {
    return a > b ? a : b;
}

int main() {
    if(!al_init()){
        printf("Failed to initialize allegro!\n");
        return -1;
    }
    if(!al_install_keyboard()){
        printf("Failed to initialize the keyboard!\n");
        return -1;
    }

    ALLEGRO_TIMER *timer = al_create_timer(TIME_STEP);
    if(!timer){
        printf("Failed to create timer!\n");
        return -1;
    }
    ALLEGRO_EVENT_QUEUE *queue = al_create_event_queue();
    if(!queue){
        printf("Failed to create event queue!\n");
        return -1;
    }
    ALLEGRO_DISPLAY *disp = al_create_display(WIDTH, HEIGHT);
    if(!disp){
        printf("Failed to create display!\n");
        return -1;
    }

    al_register_event_source(queue, al_get_keyboard_event_source());
    al_register_event_source(queue, al_get_timer_event_source(timer));

    bool update = true;
    ALLEGRO_EVENT event;

    uint8_t *pixels = malloc(WIDTH * HEIGHT * 3);
    double cReal, cImag, scale, offsetReal, offsetImag;
    restart_params(&cReal, &cImag, &scale, &offsetReal, &offsetImag);
    double escapeRadius = ESCAPE_RADIUS;

    juliaSet(pixels, WIDTH, HEIGHT, escapeRadius, cReal, cImag, offsetReal, offsetImag, scale);
    displayRGBPixels(pixels, WIDTH, HEIGHT);

    al_start_timer(timer);
    while (true) {
        al_wait_for_event(queue, &event);
        if (event.type == ALLEGRO_EVENT_KEY_CHAR) {
            if (event.keyboard.keycode == ALLEGRO_KEY_ESCAPE) {
                break;
            }
            if (event.keyboard.keycode == ALLEGRO_KEY_J) {
                cReal -= SMALL_CHANGE;
            } else if (event.keyboard.keycode == ALLEGRO_KEY_L) {
                cReal += SMALL_CHANGE;
            } else if (event.keyboard.keycode == ALLEGRO_KEY_I) {
                cImag += SMALL_CHANGE;
            } else if (event.keyboard.keycode == ALLEGRO_KEY_K) {
                cImag -= SMALL_CHANGE;
            }
            if (event.keyboard.keycode == ALLEGRO_KEY_W) {
                cImag += BIG_CHANGE;
            } else if (event.keyboard.keycode == ALLEGRO_KEY_A) {
                cReal -= BIG_CHANGE;
            } else if (event.keyboard.keycode == ALLEGRO_KEY_S) {
                cImag -= BIG_CHANGE;
            } else if (event.keyboard.keycode == ALLEGRO_KEY_D) {
                cReal += BIG_CHANGE;
            }
            if (event.keyboard.keycode == ALLEGRO_KEY_MINUS) {
                scale = max(scale - SCALE_CHANGE, 0);
            } else if (event.keyboard.keycode == ALLEGRO_KEY_EQUALS) {
                scale += SCALE_CHANGE;
            }
            if (event.keyboard.keycode == ALLEGRO_KEY_R) {
                restart_params(&cReal, &cImag, &scale, &offsetReal, &offsetImag);
            }
            if (event.keyboard.keycode == ALLEGRO_KEY_UP) {
                offsetImag -= OFFSET_CHANGE;
            } else if (event.keyboard.keycode == ALLEGRO_KEY_LEFT) {
                offsetReal -= OFFSET_CHANGE;
            } else if (event.keyboard.keycode == ALLEGRO_KEY_DOWN) {
                offsetImag += OFFSET_CHANGE;
            } else if (event.keyboard.keycode == ALLEGRO_KEY_RIGHT) {
                offsetReal += OFFSET_CHANGE;
            }
            update = true;
        } else if (event.type == ALLEGRO_EVENT_DISPLAY_CLOSE) {
            break;
        }
        if (update && al_is_event_queue_empty(queue)) {
            juliaSet(pixels, WIDTH, HEIGHT, escapeRadius, cReal, cImag, offsetReal, offsetImag, scale);
            displayRGBPixels(pixels, WIDTH, HEIGHT);
            al_flip_display();
            update = false;
        }
    }
    al_destroy_display(disp);
    al_destroy_timer(timer);
    al_destroy_event_queue(queue);
    free(pixels);
    return 0;
}