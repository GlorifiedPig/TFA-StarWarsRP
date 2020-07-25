
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

if not CLIENT then return end

TFA.Fonts = TFA.Fonts or {}

if not TFA.Fonts.SleekFontCreated then
	local fontdata = {}
	fontdata.font = "Roboto"
	fontdata.shadow = false
	fontdata.extended = true
	fontdata.size = 36
	surface.CreateFont("TFASleek", fontdata)
	TFA.Fonts.SleekHeight = draw.GetFontHeight("TFASleek")
	fontdata.size = 30
	surface.CreateFont("TFASleekMedium", fontdata)
	TFA.Fonts.SleekHeightMedium = draw.GetFontHeight("TFASleekMedium")
	fontdata.size = 24
	surface.CreateFont("TFASleekSmall", fontdata)
	TFA.Fonts.SleekHeightSmall = draw.GetFontHeight("TFASleekSmall")
	fontdata.size = 18
	surface.CreateFont("TFASleekTiny", fontdata)
	TFA.Fonts.SleekHeightTiny = draw.GetFontHeight("TFASleekTiny")
	TFA.Fonts.SleekFontCreated = true
end

if not TFA.InspectionFontsCreated then
	local fontdata = {}
	fontdata.font = "Roboto"
	fontdata.extended = true
	fontdata.weight = 500
	fontdata.size = 64
	surface.CreateFont("TFA_INSPECTION_TITLE", fontdata)
	fontdata.size = 32
	surface.CreateFont("TFA_INSPECTION_DESCR", fontdata)
	fontdata.size = 24
	surface.CreateFont("TFA_INSPECTION_SMALL", fontdata)

	TFA.InspectionFontsCreated = true
end