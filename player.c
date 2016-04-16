#include "SDL2/SDL.h"
#include "player.h"

Player Player_create(int x, int y) {
	return (Player){
		(SDL_Rect){ x, y, 45, 56 }
	};
}

int Player_render(SDL_Renderer* renderer, Player player) {
	return SDL_RenderFillRect(renderer, &player.rect);
}
