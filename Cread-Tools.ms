/* 
	Cread Tools
	MastaMan
	GNU  GPL v3.0
	
	Tools for Cread
	
	Changelog:
	
	v.1.0.0
	Initial release
	
	v.1.0.1
	- BugFix: Adopt for new V-Ray
	
	v.1.0.2
	+ Added buttons: "NormalBump > VrayNormalMap" and "ColorCorrect > ColorCorrection"
	* Optimized: Fix Vray2SidedMtl
*/

try(closeRolloutFloater fCreadTools)catch()
global fCreadTools = newRolloutFloater "Cread Tools" 200 180
global rShaders

rollout rShaders "Shaders"
(
	button btnStartFix "Fix Vray2SidedMtl" width: 170
	button btnReplaceNormal "NormalBump > VrayNormalMap" width: 170
	button btnReplaceColorCorrect "ColorCorrect > ColorCorrection" width: 170

	----------------------------------------------------------------------------------------------------------------
	
	fn findRenderer f =
	(	
		o = for r in RendererClass.classes where matchPattern (r as string) pattern: ("*" + f + "*") collect r
		return o.count > 0
	)
	
	----------------------------------------------------------------------------------------------------------------
	
	fn replaceNormal = 
	(
		if(findRenderer "V_Ray" == false) do return messageBox "Please choose V-Ray Renderer" title: "Warning!"
		
		iNrmCnt = 0
		clearListener()
		for i in getClassInstances VrayMtl do
		(
			b = i.texmap_bump
			
			if(b == undefined or classOf b != Normal_Bump) do continue
			
			nrm = b.normal_map 
						
			replaceInstances b (VRayNormalMap normal_map: nrm)
			
			iNrmCnt += 1
		)
		
		messageBox ("Fixed NormalMap: "  + iNrmCnt as string) title: "Success!"
	)
	
	fn replaceColorCorrect =
	(
		if(findRenderer "V_Ray" == false) do return messageBox "Please choose V-Ray Renderer" title: "Warning!"		
		if(colorcorrect == undefined) do return messageBox "Nothing to fix!\nColorCorrect Plugin not installed!" title: "Warning!"		
		
		iColorCnt = 0 
		
		clearListener()
		-- Code by crazy1k
		for m in (getClassinstances colorcorrect) do
		(
			mcc_gamma=1/m.gamma
			mcc_color=m.src_color
			if m.hsl_on==true then 
			(
				mcc_sat=m.hsl_sat_off/1.32+(m.hsl_sat_gain-100)/2.66
				mcc_hue_off=m.hsl_hue_off
			)
			if m.hsv_on==true then 
			(
				mcc_sat=m.hsv_sat_off/1.32+(m.hsv_sat_gain-100)/2.66
				mcc_hue_off=m.hsv_hue_off
			)
			mcc_mono=m.pre_mono
			mcc_invert=m.pre_invert
			if m.pre_on==true and (m.hsl_on==true or m.hsv_on==true) then
			(
				if (mcc_mono==false) and (mcc_invert==false) then replaceInstances m (color_correction color:mcc_color map:(getSubTexmap m 1) hueShift:mcc_hue_off saturation:mcc_sat gammaRGB:mcc_gamma lightnessMode:1)
				if (mcc_mono==true) and (mcc_invert==false) then replaceInstances m (color_correction color:mcc_color map:(getSubTexmap m 1) hueShift:mcc_hue_off saturation:mcc_sat gammaRGB:mcc_gamma rewireMode:1 lightnessMode:1)
				if (mcc_mono==false) and (mcc_invert==true) then replaceInstances m (color_correction color:mcc_color map:(getSubTexmap m 1) hueShift:mcc_hue_off saturation:mcc_sat gammaRGB:mcc_gamma rewireMode:2 lightnessMode:1)
			)
			if m.pre_on==true and (m.hsl_on==false and m.hsv_on==false) then 
			(
				if (mcc_mono==false) and (mcc_invert==false) then replaceInstances m (color_correction color:mcc_color map:(getSubTexmap m 1) gammaRGB:mcc_gamma lightnessMode:1)
				if (mcc_mono==true) and (mcc_invert==false) then replaceInstances m (color_correction color:mcc_color map:(getSubTexmap m 1) gammaRGB:mcc_gamma rewireMode:1 lightnessMode:1)
				if (mcc_mono==false) and (mcc_invert==true) then replaceInstances m (color_correction color:mcc_color map:(getSubTexmap m 1) gammaRGB:mcc_gamma rewireMode:2 lightnessMode:1)
			)
			if m.pre_on==false and (m.hsl_on==true or m.hsv_on==true) then
				replaceInstances m (color_correction color:mcc_color map:(getSubTexmap m 1) hueShift:mcc_hue_off saturation:mcc_sat lightnessMode:1)
			if m.pre_on==false and (m.hsl_on==false and m.hsv_on==false) then
					replaceInstances m (color_correction color:mcc_color map:(getSubTexmap m 1) lightnessMode:1)
		
			iColorCnt += 1
		)
		
		messageBox ("Fixed ColorCorrect: "  + iColorCnt as string) title: "Success!"
	)
	
	fn fix2Sided =
	(
		if(findRenderer "V_Ray" == false) do return messageBox "Please choose V-Ray Renderer" title: "Warning!"
		
		/*fn is2Sided m =
		(
			return classOf m == Vray2SidedMtl
		)
		
		undo "Fix Vray2SidedMtl" on 
		(	
			mCount = 0
			for i in geometry where i.material != undefined do
			(
				case (classOf i.material) of
				(
					MultiMaterial: 
					(
						for ii in 1 to i.material.count where is2Sided (i.material[ii]) do 
						(
							i.material[ii] = i.material[ii].frontMtl
							mCount += 1
						)
					)
					default: 
					(
						if(is2Sided (i.material)) do 
						(
							i.material = i.material.frontMtl
							mCount += 1
						)						
					)
				)
			)
		)*/
		
		mCount = 0
		clearListener()
		
		for i in getClassInstances Vray2SidedMtl do
		(
			f = i.frontMtl
												
			replaceInstances i f
			
			mCount += 1
		)
		
		messageBox ("Fixed materials: "  + mCount as string) title: "Success!"
	)
	
	----------------------------------------------------------------------------------------------------------------
	
	on btnStartFix pressed do fix2Sided()	
	on btnReplaceNormal pressed do replaceNormal()
	on btnReplaceColorCorrect pressed do replaceColorCorrect()
)

rollout rAbout "About" 
(
	label lblName "MastaMan" 
	label lblVer "1.0.2" 
	
	label lblAuthor "MastaMan" height: 30
	label lblCopy "GNU GPL v3.0"  height: 30
)

addRollout rShaders fCreadTools rolledUp:false 
addRollout rAbout fCreadTools rolledUp:true