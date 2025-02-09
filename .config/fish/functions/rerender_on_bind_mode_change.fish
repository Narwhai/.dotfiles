function rerender_on_bind_mode_change --on-variable fish_bind_mode
    if test "$fish_bind_mode" != paste
        omp_repaint_prompt
    end
end
