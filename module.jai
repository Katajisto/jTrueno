#import "Basic";
#import "Process";

SDL     :: #import "SDL3";
SDL_IMG :: #import "SDL3/image";
Jaison  :: #import "Jaison";

#load "rendering/base.jai";
#load "editor/base.jai";
#load "yaris/base.jai";
#load "input/base.jai";
#load "trile/base.jai";



compile_shaders :: () {
    print(" -- Compiling shaders! --\n");
    res := run_command("bash", "./compile.sh", working_directory=tprint("%shaders", #filepath));
    if res.exit_code != 0 {
        print(" --- Shader compilation failed, aborting build! --- \n\n");
        exit(1);
    }
    print(" -- Shaders OK! -- \n");
}

#run {
    compile_shaders();
}



main :: () {
    ok := init(700, 700, "jTrueno!");
    editorState : Editor_State;

    quit := false;
   
    init_ui();

    while !quit {
        quit = input_begin_frame();
        trile_editor_tick(*editorState);

        tick_ui();

        draw(*editorState);
        reset_temporary_storage();
    }
}
