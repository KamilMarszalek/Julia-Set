#include <allegro5/allegro5.h>
#include <allegro5/allegro_font.h>
#include "juliaSet.h"
#include "constants.h"



double max(double a, double b) {
    return a > b ? a : b;
}

void displayRGBPixels(uint8_t pixels[], int width, int height) {
    for (int row = 0; row < height; row++) {
        for (int col = 0; col < width; col++) {
            int pixelIndex = 3 * (row * width + col);
            al_draw_pixel(col, row, al_map_rgb(pixels[pixelIndex], pixels[pixelIndex + 1],pixels[pixelIndex + 2]));
        }
    }
}

int main() {
    al_init();
    al_install_keyboard();

    ALLEGRO_TIMER *timer = al_create_timer(TIME_STEP);
    ALLEGRO_EVENT_QUEUE *queue = al_create_event_queue();
    ALLEGRO_DISPLAY *disp = al_create_display(WIDTH, HEIGHT);
    ALLEGRO_FONT *font = al_create_builtin_font();

    al_register_event_source(queue, al_get_keyboard_event_source());
    al_register_event_source(queue, al_get_timer_event_source(timer));

    bool redraw = true;
    ALLEGRO_EVENT event;

    uint8_t *pixels = malloc(WIDTH * HEIGHT * 3);
    double offsetReal = (double)WIDTH / 2;
    double offsetImag = (double)HEIGHT / 2;
    double scale = 1.0;

    double cReal = 0.0;
    double cImag = 0.0;
    double escapeRadius = 2.0;



    juliaSet(pixels, WIDTH, HEIGHT, escapeRadius, cReal, cImag, offsetReal, offsetImag, scale);
    displayRGBPixels(pixels, WIDTH, HEIGHT);


    al_start_timer(timer);
    while (true) {
        al_wait_for_event(queue, &event);

        if (event.type == ALLEGRO_EVENT_KEY_CHAR) {
            if (event.keyboard.keycode == ALLEGRO_KEY_ESCAPE) {
                break;
            }

            if (event.keyboard.keycode == ALLEGRO_KEY_LEFT) {
                cReal -= C_CHANGE;
            } else if (event.keyboard.keycode == ALLEGRO_KEY_RIGHT) {
                cReal += C_CHANGE;
            } else if (event.keyboard.keycode == ALLEGRO_KEY_UP) {
                cImag += C_CHANGE;
            } else if (event.keyboard.keycode == ALLEGRO_KEY_DOWN) {
                cImag -= C_CHANGE;
            }

            if (event.keyboard.keycode == ALLEGRO_KEY_W) {
                offsetImag -= OFFSET_CHANGE;
            } else if (event.keyboard.keycode == ALLEGRO_KEY_A) {
                offsetReal -= OFFSET_CHANGE;
            } else if (event.keyboard.keycode == ALLEGRO_KEY_S) {
                offsetImag += OFFSET_CHANGE;
            } else if (event.keyboard.keycode == ALLEGRO_KEY_D) {
                offsetReal += OFFSET_CHANGE;
            }

            if (event.keyboard.keycode == ALLEGRO_KEY_Q) {
                scale = max(scale - SCALE_CHANGE, 0);
            } else if (event.keyboard.keycode == ALLEGRO_KEY_E) {
                scale += SCALE_CHANGE;
            }

            redraw = true;

        } else if (event.type == ALLEGRO_EVENT_DISPLAY_CLOSE) {
            break;
        }

        if (redraw && al_is_event_queue_empty(queue)) {
            juliaSet(pixels, WIDTH, HEIGHT, escapeRadius, cReal, cImag, offsetReal, offsetImag, scale);
            displayRGBPixels(pixels, WIDTH, HEIGHT);
            al_flip_display();

            redraw = false;
        }
    }

    al_destroy_font(font);
    al_destroy_display(disp);
    al_destroy_timer(timer);
    al_destroy_event_queue(queue);

    free(pixels);
    return 0;
}