Class Demo.PETS.Owners Extends %Persistent
{

/// RUT como identificador único y clave primaria
Property RUT As %String(MAXLEN = 12) [ Required ];

Property Name As %String(MAXLEN = 100) [ Required ];

Property Phone As %String(MAXLEN = 20) [ Required ];

Property Email As %String(MAXLEN = 100);

Property Address As %String(MAXLEN = 200);

Property NumberOfPets As %Integer [ InitialExpression = 1 ];

Property Preferences As %String(MAXLEN = 500);

Property Status As %String(MAXLEN = 20) [ InitialExpression = "Active" ];

Property DateRegistered As %Date;

/// Relationship: One Owner can have Many Pets
Relationship Pets As Demo.PETS.Pets [ Cardinality = many, Inverse = Owner ];

/// Index único en RUT
Index RUTIndex On RUT [ Unique ];

/// Method to insert sample data
ClassMethod InsertSampleData() As %Status
{
    // Clear existing data
    Do ..%KillExtent()
    
    // Insert sample owners
    Set owner1 = ..%New()
    Set owner1.RUT = "12345678-9"
    Set owner1.Name = "Carlos Pérez"
    Set owner1.Phone = "555-9876"
    Set owner1.Email = "carlos@email.com"
    Set owner1.Address = "Calle Principal 123"
    Set owner1.NumberOfPets = 2
    Set owner1.Preferences = "Prefiere paseos matutinos, rutas tranquilas"
    Set owner1.Status = "Active"
    Do owner1.%Save()
    
    Set owner2 = ..%New()
    Set owner2.RUT = "15678945-2"
    Set owner2.Name = "María González"
    Set owner2.Phone = "555-2468"
    Set owner2.Email = "maria@email.com"
    Set owner2.Address = "Av. Central 456"
    Set owner2.NumberOfPets = 1
    Set owner2.Preferences = "Paseos largos en el parque, horarios flexibles"
    Set owner2.Status = "Active"
    Do owner2.%Save()
    
    Set owner3 = ..%New()
    Set owner3.RUT = "87654321-K"
    Set owner3.Name = "Miguel Torres"
    Set owner3.Phone = "555-1357"
    Set owner3.Email = "miguel@email.com"
    Set owner3.Address = "Calle Norte 789"
    Set owner3.NumberOfPets = 3
    Set owner3.Preferences = "Paseos cortos, evitar otros perros grandes"
    Set owner3.Status = "Active"
    Do owner3.%Save()
    
    Set owner4 = ..%New()
    Set owner4.RUT = "17890165-4"
    Set owner4.Name = "Ana Martínez"
    Set owner4.Phone = "555-8642"
    Set owner4.Email = "ana.m@email.com"
    Set owner4.Address = "Calle Sur 321"
    Set owner4.NumberOfPets = 1
    Set owner4.Preferences = "Paseos energéticos, socialización con otros perros"
    Set owner4.Status = "Active"
    Do owner4.%Save()
    
    Return $$$OK
}

/// Get owner by RUT
ClassMethod GetOwnerByRUT(rut As %String) As Demo.PETS.Owners
{
    &sql(SELECT ID INTO :id FROM Demo_PETS.Owners WHERE RUT = :rut)
    If SQLCODE = 0 {
        Return ..%OpenId(id)
    }
    Return ""
}

/// Get owner by ID
ClassMethod GetOwnerById(id As %Integer) As Demo.PETS.Owners
{
    Return ..%OpenId(id)
}

/// Get all owners
ClassMethod GetAllOwners() As %ResultSet
{
    Set rs = ##class(%ResultSet).%New()
    Set rs.ClassName = "Demo.PETS.Owners"
    Set rs.QueryName = "Extent"
    Do rs.Execute()
    Return rs
}

Storage Default
{
<Data name="OwnersDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Name</Value>
</Value>
<Value name="3">
<Value>Phone</Value>
</Value>
<Value name="4">
<Value>Email</Value>
</Value>
<Value name="5">
<Value>Address</Value>
</Value>
<Value name="6">
<Value>NumberOfPets</Value>
</Value>
<Value name="7">
<Value>Preferences</Value>
</Value>
<Value name="8">
<Value>Status</Value>
</Value>
<Value name="9">
<Value>DateRegistered</Value>
</Value>
<Value name="10">
<Value>RUT</Value>
</Value>
</Data>
<DataLocation>^Demo.PETS.OwnersD</DataLocation>
<DefaultData>OwnersDefaultData</DefaultData>
<ExtentSize>4</ExtentSize>
<IdLocation>^Demo.PETS.OwnersD</IdLocation>
<IndexLocation>^Demo.PETS.OwnersI</IndexLocation>
<Property name="%%CLASSNAME">
<AverageFieldSize>2</AverageFieldSize>
<OutlierSelectivity>.999999:</OutlierSelectivity>
<Selectivity>0.0001%</Selectivity>
</Property>
<Property name="%%ID">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="Address">
<AverageFieldSize>17.5</AverageFieldSize>
<Selectivity>25.0000%</Selectivity>
</Property>
<Property name="DateRegistered">
<AverageFieldSize>2</AverageFieldSize>
<OutlierSelectivity>.999999:</OutlierSelectivity>
<Selectivity>0.0001%</Selectivity>
</Property>
<Property name="Email">
<AverageFieldSize>17.75</AverageFieldSize>
<Selectivity>25.0000%</Selectivity>
</Property>
<Property name="Name">
<AverageFieldSize>14.25</AverageFieldSize>
<Selectivity>25.0000%</Selectivity>
</Property>
<Property name="NumberOfPets">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>33.3333%</Selectivity>
</Property>
<Property name="Phone">
<AverageFieldSize>10</AverageFieldSize>
<Selectivity>25.0000%</Selectivity>
</Property>
<Property name="Preferences">
<AverageFieldSize>47.25</AverageFieldSize>
<Selectivity>25.0000%</Selectivity>
</Property>
<Property name="Status">
<AverageFieldSize>8</AverageFieldSize>
<OutlierSelectivity>.999999:"Active"</OutlierSelectivity>
<Selectivity>0.0001%</Selectivity>
</Property>
<SQLMap name="IDKEY">
<BlockCount>-4</BlockCount>
</SQLMap>
<StreamLocation>^Demo.PETS.OwnersS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
