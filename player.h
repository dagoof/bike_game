#include "SDL2/SDL.h"

typedef struct _Player {
	SDL_Rect rect;
} Player;

Player Player_create(int, int);

int Player_render(SDL_Renderer* renderer, Player player);
