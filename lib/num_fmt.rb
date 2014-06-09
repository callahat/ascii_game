#This module contains number formatting functions
module NumFmt

    #Takes a number and returns the most significant digits and any quantifiers, such as K(ilo) or M(illion)
    def NumFmt.human(number)
        hn = number.to_s
        return(hn) if hn.size < 7
        ret = hn[0..((hn.size-1)%3)]
        ret += ".#{hn[((hn.size)%3)..2]}" unless hn.size%3 == 0
        (ret + "&nbsp;" +  HUMAN_ABRV[(hn.size-1)/3]).html_safe
    end
end
