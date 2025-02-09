SDL :: #import "SDL3";
#import "Basic";
supra :: #import,file "supra.jai";
yaris :: #import "Yaris";

main :: () {
    supra_c, ok := supra.init(700, 700, "jTrueno!");

    quit := false;
   
    while !quit {
        evt: SDL.Event;
        while(SDL.poll_event(*evt)) {
            if evt.type == SDL.Event_Type.QUIT {
                quit = true;
                break;
            }
        }
        supra.draw(*supra_c);
    }
}
