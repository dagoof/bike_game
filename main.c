#include "SDL2/SDL.h"
#include "SDL2/SDL_ttf.h"
#include "stdlib.h"
#include "player.h"

const int width = 144;
const int height = 256;
const int font_size = 10;

SDL_Color white = { 0xFF, 0xFF, 0xFF };

int main() {
	SDL_Init(SDL_INIT_VIDEO);

	SDL_Window* window;
	SDL_Renderer* renderer;
	SDL_CreateWindowAndRenderer(width, height, SDL_WINDOW_SHOWN, &window, &renderer);

	SDL_Log("yeah this owns dick %s", "all the dicks");
	SDL_SetRenderDrawColor(renderer, 0xFF, 0xFF, 0xFF, 0xFF);

	SDL_Rect rect = { 0, 0, 50, 50 };
	SDL_RenderFillRect(renderer, &rect);

	Player player = Player_create(25, 25);
	Player_render(renderer, player);

	TTF_Init();
	TTF_Font* munro = TTF_OpenFont("Munro.ttf", font_size);

	SDL_Surface* textS = TTF_RenderText_Solid(
		munro,
		"Gametiem",
		white
	);

	SDL_Texture* textT = SDL_CreateTextureFromSurface(renderer, textS);
	SDL_Rect placement = { 15, 128, textS->w, textS->h };
	SDL_RenderCopy(renderer, textT, NULL, &placement);
	SDL_FreeSurface(textS);
	SDL_DestroyTexture(textT);

	SDL_RenderPresent(renderer);

	SDL_Delay(2000l);
	TTF_CloseFont(munro);
	TTF_Quit();
	SDL_DestroyRenderer(renderer);
	SDL_DestroyWindow(window);
	SDL_Quit();

	return 0;
}

