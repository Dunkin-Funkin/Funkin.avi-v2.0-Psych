function onUpdate() 
    if not botPlay and keyJustPressed('space') then
        health = getProperty('health')
        if getProperty('health') then
            setProperty('health', health+ 0.03) 
        end
    end
      end

    function onBeatHit()
        if not botPlay then
        health = getProperty('health')
        setProperty('health', health- 0.04)
    end
end

    function goodNoteHit()
              if getProperty('health') then
                  setProperty('health', health+ 0.0)
              end
            end 

    function onUpdatePost()
        if not botPlay then
        setProperty('scoreTxt.visible', false)
        setProperty('timeBar.visible', false)
        setProperty('timeBarBG.visible', false)
        setProperty('iconP1.visible', false)
	  setProperty('iconP2.visible', false)
        setProperty('timeTxt.visible', false);
	  setProperty('opponentStrums.visible', false);
    end
end

   function onCreate()
    if not botPlay then
        makeLuaText('warning', "Press 'Space' For Gain health", 1100, 100)
        addLuaText('warning', 'Press Dark Notes For Gain health')
        setTextSize('warning', 32)
        setTextColor('warning', '0xFFFFFF')
        setTextFont('warning', 'vcr.ttf')
        --NGL i finally know how to make custom text without a tutorial

    end
end