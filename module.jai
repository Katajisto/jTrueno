#import "Basic";
#import "Process";

SDL :: #import,dir "./modules/SDL3";

SDL3_Type_Indicator :: struct {
    Window_Type : Type : SDL.Window;
    Font: Type;
    Font_Effects: Type;
    Texture: Type;    
};

indicator :: SDL3_Type_Indicator.{
    SDL.Window,
    u32,
    u32,
    SDL.Texture
};

GR :: #import "GetRect_LeftHanded"()(Type_Indicator = type_of(indicator));

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
    supra_c, ok := init(700, 700, "jTrueno!");
    editorState : Editor_State;

    quit := false;
   
    while !quit {
        quit = input_begin_frame();
        trile_editor_tick(*editorState);

        draw(*supra_c, *editorState);
        reset_temporary_storage();
    }
}
