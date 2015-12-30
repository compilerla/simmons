class Colorizer
  COLORS = [
    '#B9CE2C', 
    '#C1AE0F', 
    '#A5CD7C', 
    '#1F4864',
    '#03BDC7', 
    '#780463', 
    '#125B05', 
    '#ABB792', 
    '#3A2838', 
    '#C3C718', 
    '#E90FE6', 
    '#3F98A9', 
    '#E559DE', 
    '#C09E8D', 
    '#7503C2', 
    '#BBBCA9', 
    '#3E9C74', 
    '#659CF7', 
    '#AC74A0', 
    '#115242', 
    '#40D0D8', 
    '#A073DE', 
    '#8342F4', 
    '#9A00EB',
    '#10C721'
  ]

  def initialize
    @lists = []
  end

  def colorize(lists)
    if lists.is_a? Array
      COLORS.last
    else
      unless @lists.include?(lists)
        @lists << lists
      end
      COLORS[@lists.find_index(lists)]
    end
  end
end