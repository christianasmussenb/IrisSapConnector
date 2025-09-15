Class Demo.PETS.Pets Extends %Persistent
{

/// ID único tipo userid para cada mascota
Property UserID As %String(MAXLEN = 50) [ Required ];

Property Name As %String(MAXLEN = 100) [ Required ];

Property Breed As %String(MAXLEN = 50);

Property Age As %Integer;

Property Weight As %Numeric(SCALE = 2);

Property Size As %String(MAXLEN = 20);

Property Color As %String(MAXLEN = 50);

Property Status As %String(MAXLEN = 20) [ InitialExpression = "Active" ];

/// Relationship: Each Pet belongs to One Owner
Relationship Owner As Demo.PETS.Owners [ Cardinality = one, Inverse = Pets, Required ];

Property Temperament As %String(MAXLEN = 100);

Property Notes As %String(MAXLEN = 500);

Property DateRegistered As %Date;

/// Index único en UserID
Index UserIDIndex On UserID [ Unique ];

/// Method to insert sample data
ClassMethod InsertSampleData() As %Status
{
    // Clear existing data
    Do ..%KillExtent()
    
    // First ensure we have owners to reference
    Set rs = ##class(%SQL.Statement).%ExecDirect(,"SELECT COUNT(*) as Total FROM Demo_PETS.Owners")
    Do rs.%Next()
    If rs.%Get("Total") = 0 {
        Do ##class(Demo.PETS.Owners).InsertSampleData()
    }
    
    // Insert sample pets with proper owner relationships
    Set owner1 = ##class(Demo.PETS.Owners).%OpenId(1)
    Set owner2 = ##class(Demo.PETS.Owners).%OpenId(2)
    Set owner3 = ##class(Demo.PETS.Owners).%OpenId(3)
    Set owner4 = ##class(Demo.PETS.Owners).%OpenId(4)
    
    Set pet1 = ..%New()
    Set pet1.UserID = "user001.pet001"
    Set pet1.Name = "Rex"
    Set pet1.Breed = "Pastor Alemán"
    Set pet1.Age = 3
    Set pet1.Weight = 25.5
    Set pet1.Size = "Grande"
    Set pet1.Color = "Negro y dorado"
    Set pet1.Status = "Active"
    Set pet1.Owner = owner1
    Set pet1.Temperament = "Amigable, Enérgico"
    Set pet1.Notes = "Le encanta correr y jugar"
    Do pet1.%Save()
    
    Set pet2 = ..%New()
    Set pet2.UserID = "user002.pet001"
    Set pet2.Name = "Luna"
    Set pet2.Breed = "Golden Retriever"
    Set pet2.Age = 2
    Set pet2.Weight = 22.0
    Set pet2.Size = "Grande"
    Set pet2.Color = "Dorado"
    Set pet2.Status = "Active"
    Set pet2.Owner = owner2
    Set pet2.Temperament = "Gentil, Social"
    Set pet2.Notes = "Excelente con niños, ama el agua"
    Do pet2.%Save()
    
    Set pet3 = ..%New()
    Set pet3.UserID = "user003.pet001"
    Set pet3.Name = "Max"
    Set pet3.Breed = "Bulldog Francés"
    Set pet3.Age = 4
    Set pet3.Weight = 12.5
    Set pet3.Size = "Pequeño"
    Set pet3.Color = "Blanco"
    Set pet3.Status = "Active"
    Set pet3.Owner = owner3
    Set pet3.Temperament = "Tranquilo, Cariñoso"
    Set pet3.Notes = "Perfecto para apartamentos"
    Do pet3.%Save()
    
    Set pet4 = ..%New()
    Set pet4.UserID = "user004.pet001"
    Set pet4.Name = "Bella"
    Set pet4.Breed = "Labrador"
    Set pet4.Age = 5
    Set pet4.Weight = 28.0
    Set pet4.Size = "Grande"
    Set pet4.Color = "Chocolate"
    Set pet4.Status = "Active"
    Set pet4.Owner = owner4
    Set pet4.Temperament = "Enérgica, Leal"
    Set pet4.Notes = "Necesita ejercicio diario"
    Do pet4.%Save()
    
    Set pet5 = ..%New()
    Set pet5.UserID = "user001.pet002"
    Set pet5.Name = "Charlie"
    Set pet5.Breed = "Poodle"
    Set pet5.Age = 1
    Set pet5.Weight = 8.5
    Set pet5.Size = "Pequeño"
    Set pet5.Color = "Blanco"
    Set pet5.Status = "Inactive"
    Set pet5.Owner = owner1
    Set pet5.Temperament = "Inteligente, Juguetón"
    Set pet5.Notes = "Muy inteligente, ama los juguetes"
    Do pet5.%Save()
    
    Return $$$OK
}

/// Get pet by UserID
ClassMethod GetPetByUserID(userid As %String) As Demo.PETS.Pets
{
    &sql(SELECT ID INTO :id FROM Demo_PETS.Pets WHERE UserID = :userid)
    If SQLCODE = 0 {
        Return ..%OpenId(id)
    }
    Return ""
}

/// Get pet by ID
ClassMethod GetPetById(id As %Integer) As Demo.PETS.Pets
{
    Return ..%OpenId(id)
}

/// Get all pets for an owner
ClassMethod GetPetsByOwner(ownerid As %Integer) As %ResultSet
{
    Set rs = ##class(%ResultSet).%New()
    Set rs.ClassName = "Demo.PETS.Pets"
    Set rs.QueryName = "GetPetsByOwnerQuery"
    Do rs.Execute(ownerid)
    Return rs
}

/// Query to get pets by owner
Query GetPetsByOwnerQuery(ownerid As %Integer) As %SQLQuery(CONTAINID = 1)
{
    SELECT ID, UserID, Name, Breed, Age, Weight, Size, Color, Status, Temperament, Notes
    FROM Pets
    WHERE Owner = :ownerid
}

Storage Default
{
<Data name="PetsDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Name</Value>
</Value>
<Value name="3">
<Value>Breed</Value>
</Value>
<Value name="4">
<Value>Age</Value>
</Value>
<Value name="5">
<Value>Weight</Value>
</Value>
<Value name="6">
<Value>Size</Value>
</Value>
<Value name="7">
<Value>Color</Value>
</Value>
<Value name="8">
<Value>Status</Value>
</Value>
<Value name="9">
<Value>OwnerID</Value>
</Value>
<Value name="10">
<Value>Temperament</Value>
</Value>
<Value name="11">
<Value>Notes</Value>
</Value>
<Value name="12">
<Value>DateRegistered</Value>
</Value>
<Value name="13">
<Value>Owner</Value>
</Value>
<Value name="14">
<Value>UserID</Value>
</Value>
</Data>
<DataLocation>^Demo.PETS.PetsD</DataLocation>
<DefaultData>PetsDefaultData</DefaultData>
<ExtentSize>7</ExtentSize>
<IdLocation>^Demo.PETS.PetsD</IdLocation>
<IndexLocation>^Demo.PETS.PetsI</IndexLocation>
<Property name="%%CLASSNAME">
<AverageFieldSize>2</AverageFieldSize>
<OutlierSelectivity>.999999:</OutlierSelectivity>
<Selectivity>0.0001%</Selectivity>
</Property>
<Property name="%%ID">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="Age">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>20.0000%</Selectivity>
</Property>
<Property name="Breed">
<AverageFieldSize>12.29</AverageFieldSize>
<Selectivity>16.6667%</Selectivity>
</Property>
<Property name="Color">
<AverageFieldSize>9</AverageFieldSize>
<Selectivity>20.0000%</Selectivity>
</Property>
<Property name="DateRegistered">
<AverageFieldSize>2</AverageFieldSize>
<OutlierSelectivity>.999999:</OutlierSelectivity>
<Selectivity>0.0001%</Selectivity>
</Property>
<Property name="Name">
<AverageFieldSize>6.57</AverageFieldSize>
<Selectivity>16.6667%</Selectivity>
</Property>
<Property name="Notes">
<AverageFieldSize>24.14</AverageFieldSize>
<Selectivity>16.6667%</Selectivity>
</Property>
<Property name="Owner">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>25.0000%</Selectivity>
</Property>
<Property name="Size">
<AverageFieldSize>8.57</AverageFieldSize>
<Selectivity>33.3333%</Selectivity>
</Property>
<Property name="Status">
<AverageFieldSize>8.29</AverageFieldSize>
<OutlierSelectivity>.857143:"Active"</OutlierSelectivity>
<Selectivity>14.2857%</Selectivity>
</Property>
<Property name="Temperament">
<AverageFieldSize>16.57</AverageFieldSize>
<Selectivity>16.6667%</Selectivity>
</Property>
<Property name="UserID">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="Weight">
<AverageFieldSize>3.86</AverageFieldSize>
<Selectivity>16.6667%</Selectivity>
</Property>
<SQLMap name="IDKEY">
<BlockCount>-4</BlockCount>
</SQLMap>
<StreamLocation>^Demo.PETS.PetsS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
