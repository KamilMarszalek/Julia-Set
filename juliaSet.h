#ifndef JULIA_SET_H
#define JULIA_SET_H
    void juliaSet(
        unsigned* pixels, 
        int width,
        int height,
        double escapeRadius,
        double cReal,
        double cImag,
        double offsetX,
        double offsetY,
        double scale);
#endif