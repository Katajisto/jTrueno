#import "Basic";
#import "Process";

SDL :: #import "SDL3";
supra :: #import,file "supra.jai";
yaris :: #import "Yaris";


#run {
    print(" -- Compiling shaders! --\n");
    res := run_command("bash", "./compile.sh", working_directory="./shaders");
    if res.exit_code != 0 {
        print(" --- Shader compilation failed, aborting build! --- \n\n");
        exit(1);
    }
    print(" -- Shaders OK! -- \n");
}

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
