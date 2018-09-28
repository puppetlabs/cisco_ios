class Example_ResourceAPI_Fact
  def self.addFact(connection, facts)
    facts['kittens'] = 'in mittens'
    facts
  end
end
