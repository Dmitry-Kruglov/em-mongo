require File.dirname(__FILE__) + '/spec_helper.rb'

describe EMMongo::Collection do
  include EM::SpecHelper

  before(:all) do
    @numbers = { 
      1 => 'one',
      2 => 'two',
      3 => 'three',
      4 => 'four',
      5 => 'five',
      6 => 'six',
      7 => 'seven',
      8 => 'eight',
      9 => 'nine'
    }
  end

  after(:all) do
  end

  it 'should insert an object' do
    EM::Spec::Mongo.collection do |collection|
      obj = collection.insert(:hello => 'world')
      obj.keys.should include :_id
      obj[:_id].should be_a_kind_of String
      obj[:_id].length.should == 24
      EM::Spec::Mongo.close
    end
  end

  it 'should find an object' do
    EM::Spec::Mongo.collection do |collection|
      collection.insert(:hello => 'world') 
      r = collection.find({:hello => "world"},{}) do |res|
        res.size.should >= 1
        res[0][:hello].should == "world"
        EM::Spec::Mongo.close
      end
    end
  end

  it 'should find all objects' do
    EM::Spec::Mongo.collection do |collection|
      collection.insert(:one => 'one')
      collection.insert(:two => 'two')
      collection.find do |res|
        res.size.should >= 2
        EM::Spec::Mongo.close
      end
    end
  end

  it 'should remove an object' do
    EM::Spec::Mongo.collection do |collection|
      obj = collection.insert(:hello => 'world')
      collection.remove(obj)
      collection.find({:hello => "world"}) do |res|
        res.size.should == 0
        EM::Spec::Mongo.close
      end
    end
  end

  it 'should remove all objects' do
    EM::Spec::Mongo.collection do |collection|
      collection.insert(:one => 'one')
      collection.insert(:two => 'two')
      collection.remove
      collection.find do |res|
        res.size.should == 0
        EM::Spec::Mongo.close
      end
    end
  end

  it 'should insert a complex object' do
    EM::Spec::Mongo.collection do |collection|
      obj = {
        :array => [1,2,3],
        :float => 123.456,
        :hash => {:boolean => true},
        :nil => nil,
        :symbol => :name,
        :string => 'hello world',
        :time => Time.at(Time.now.to_i),
        :regex => /abc$/ix
      }
      obj = collection.insert(obj)
      collection.find(:_id => obj[:_id]) do |ret|
        ret.should == [ obj ]
        EM::Spec::Mongo.close
      end
    end
  end

  it 'should find an object using nested properties' do
    EM::Spec::Mongo.collection do |collection|
      collection.insert({
        :name => 'Google',
        :address => {
          :city => 'Mountain View',
          :state => 'California'}
      })

      collection.first('address.city' => 'Mountain View') do |res|
        res[:name].should == 'Google'
        EM::Spec::Mongo.close
      end
    end
  end

  it 'should find objects with specific values' do
    EM::Spec::Mongo.collection do |collection|
      @numbers.each do |num, word|
        collection.insert(:num => num, :word => word)
      end

      collection.find({:num => {'$in' => [1,3,5]}}) do |res|
        res.size.should == 3
        res.map{|r| r[:num] }.sort.should == [1,3,5]
        EM::Spec::Mongo.close
      end
    end
  end

  it 'should find objects greater than something' do
    EM::Spec::Mongo.collection do |collection|
      @numbers.each do |num, word|
        collection.insert(:num => num, :word => word)
      end

      collection.find({:num => {'$gt' => 3}}) do |res|
        res.size.should == 6
        res.map{|r| r[:num] }.sort.should == [4,5,6,7,8,9]
        EM::Spec::Mongo.close
      end
    end
  end

end
