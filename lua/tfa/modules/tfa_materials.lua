
-- Copyright (c) 2018-2020 TFA Base Devs

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

if CLIENT then
	TFA_SCOPE_ACOG = {
		scopetex = surface.GetTextureID("scope/gdcw_closedsight"),
		reticletex = surface.GetTextureID("scope/gdcw_acogchevron"),
		dottex = surface.GetTextureID("scope/gdcw_acogcross")
	}

	TFA_SCOPE_MILDOT = {
		scopetex = surface.GetTextureID("scope/gdcw_scopesight")
	}

	TFA_SCOPE_SVD = {
		scopetex = surface.GetTextureID("scope/gdcw_svdsight")
	}

	TFA_SCOPE_PARABOLIC = {
		scopetex = surface.GetTextureID("scope/gdcw_parabolicsight")
	}

	TFA_SCOPE_ELCAN = {
		scopetex = surface.GetTextureID("scope/gdcw_elcansight"),
		reticletex = surface.GetTextureID("scope/gdcw_elcanreticle")
	}

	TFA_SCOPE_GREENDUPLEX = {
		scopetex = surface.GetTextureID("scope/gdcw_closedsight"),
		reticletex = surface.GetTextureID("scope/gdcw_nvgilluminatedduplex")
	}

	TFA_SCOPE_AIMPOINT = {
		scopetex = surface.GetTextureID("scope/gdcw_closedsight"),
		reticletex = surface.GetTextureID("scope/aimpoint")
	}

	TFA_SCOPE_MATADOR = {
		scopetex = surface.GetTextureID("scope/rocketscope")
	}

	TFA_SCOPE_SCOPESCALE = 4
	TFA_SCOPE_RETICLESCALE = 1
	TFA_SCOPE_DOTSCALE = 1
end
