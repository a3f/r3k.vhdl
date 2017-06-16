#include <stdint.h>

int stdvga_palette_write(uint8_t *buf);
int stdvga_fb_write(uint8_t *buf);

#define WIDTH 640
#define HEIGHT 480

uint8_t image[WIDTH * HEIGHT];
uint8_t palette[256 * 3];

void prepare_palette(void)
{
    for (unsigned int i = 0; i < 256; i++) {
        palette[i * 3 + 0] = i;
        palette[i * 3 + 1] = i * i / 255;
        palette[i * 3 + 2] = i / 255;
    }
    stdvga_palette_write(palette);
}

void display_image(void)
{
    stdvga_fb_write(image);
}

typedef uint8_t color_t;
typedef color_t shader_t(unsigned, unsigned);
static inline shader_t sierpinski;

shader_t *shader = sierpinski;

void demo(void)
{
    prepare_palette();

    for (unsigned int y = 0; y < HEIGHT; y++) {
        for (unsigned int x = 0; x < WIDTH; x++) {
            image[y * WIDTH + x] = shader(x, y);
        }
    }

    /* Draw color scale at the top of the screen. */
    for (unsigned int x = 0; x < WIDTH; x++) {
        int q = 256 * x / WIDTH;
        image[0 * WIDTH + x] = 0;
        image[1 * WIDTH + x] = q;
        image[2 * WIDTH + x] = q;
        image[3 * WIDTH + x] = q;
        image[4 * WIDTH + x] = q;
        image[5 * WIDTH + x] = q;
        image[6 * WIDTH + x] = 0;
    }

    display_image();
}

static inline color_t sierpinski(unsigned x, unsigned y)
{
    while(x>0 || y>0) // when either of these reaches zero the pixel is determined to be on the edge 
                               // at that square level and must be filled
    {
        if(x%3==1 && y%3==1) //checks if the pixel is in the center for the current square level
            return 0;
        x /= 3; //x and y are decremented to check the next larger square level
        y /= 3;
    }
    return 0xFF; // if all possible square levels are checked and the pixel is not determined 
                   // to be open it must be filled
}

