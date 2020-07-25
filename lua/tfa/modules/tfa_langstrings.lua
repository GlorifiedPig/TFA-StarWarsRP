
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

local langstrings = {
	["en"] = {
		["nag_1"] = "Dear ",
		["nag_2"] = ", please take a moment to join TFA Mod News.  We'd be honored to have you as the ",
		["nag_3"] = "th member.  As soon as you join, you'll stop seeing this message.  You will see this a maximum of 5 times; this is #",
		["thank_1"] = "Thank you, ",
		["thank_2"] = ", for joining TFA Mod News!  You are member #"
	},
	["fr"] = {
		["nag_1"] = "Cher(chère) ",
		["nag_2"] = ", veuillez prendre un moment pour vous inscrire aux actualités de TFA. Nous serions honorés de vous avoir en tant que ",
		["nag_3"] = "ème membre. Dès que vous vous inscrirez, vous ne verrez plus ce message. Vous verrez ceci un maximum de 5 fois ; c'est #",
		["thank_1"] = "Merci, ",
		["thank_2"] = ", pour avoir rejoint les actualités de TFA ! Vous êtes membre #"
	},
	["ru"] = {
		["nag_1"] = "Уважаемый (ая) ",
		["nag_2"] = ", пожалуйста, найдите время, чтобы присоединиться к группе TFA Mod News. Мы будем очень рады видеть вас в качестве ",
		["nag_3"] = "-го участника группы. Как только вы присоединитесь к нам, вы перестанете видеть это сообщение. Вы увидите это максимум 5 раз, это ",
		["thank_1"] = "Спасибо, ",
		["thank_2"] = ", за присоединение к TFA Mod News! Вы участник под номером "
	},
	["ge"] = {
		["nag_1"] = "Herr/Frau ",
		["nag_2"] = ", bitte nehmen sie ein Moment sich TFA Mod News anschließen.  Wir würden uns geehrt um haben Sie als unser ",
		["nag_3"] = ". Mitglied.  Wenn Sie anschließen, Sie sehen dies nie wieder werden.  Sie werden dies nur fünfmal sehen; das war #",
		["thank_1"] = "Danken Sie, ",
		["thank_2"] = ", für TFA Mod News anschließen!  Sie sind Mitgleid #"
	}
}

local languages = {
	["be"] = "fr",
	["de"] = "ge",
	["at"] = "ge",
	["fr"] = "fr",
	["ru"] = "ru",
}

function TFA.GetLangString( str, country )
	local cc = country or system.GetCountry()
	local lang = languages[cc] or "en"
	local res = langstrings[lang][str] or langstrings["en"][str]
	return res
end