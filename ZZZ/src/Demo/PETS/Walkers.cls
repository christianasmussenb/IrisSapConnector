Class Demo.PETS.Walkers Extends %Persistent
{

/// RUT como identificador único y clave primaria
Property RUT As %String(MAXLEN = 12) [ Required ];

Property Name As %String(MAXLEN = 100) [ Required ];

Property Phone As %String(MAXLEN = 20) [ Required ];

Property Email As %String(MAXLEN = 100);

Property Age As %Integer;

Property Experience As %Integer;

Property Availability As %String(MAXLEN = 50);

Property HourlyRate As %Numeric(SCALE = 2);

Property Notes As %String(MAXLEN = 500);

Property Status As %String(MAXLEN = 20) [ InitialExpression = "Available" ];

Property DateRegistered As %Date;

/// Index único en RUT
Index RUTIndex On RUT [ Unique ];

/// Method to insert sample data
ClassMethod InsertSampleData() As %Status
{
    // Clear existing data
    Do ..%KillExtent()
    
    // Insert sample walkers
    Set walker1 = ..%New()
    Set walker1.RUT = "15678945-2"
    Set walker1.Name = "María González"
    Set walker1.Phone = "555-1234"
    Set walker1.Email = "maria@email.com"
    Set walker1.Age = 28
    Set walker1.Experience = 3
    Set walker1.Availability = "Tiempo completo"
    Set walker1.HourlyRate = 15.00
    Set walker1.Notes = "3 años cuidando mascotas, certificada en primeros auxilios"
    Set walker1.Status = "Available"
    Do walker1.%Save()
    
    Set walker2 = ..%New()
    Set walker2.RUT = "12345678-9"
    Set walker2.Name = "Carlos Pérez"
    Set walker2.Phone = "555-5678"
    Set walker2.Email = "carlos@email.com"
    Set walker2.Age = 35
    Set walker2.Experience = 5
    Set walker2.Availability = "Mañanas"
    Set walker2.HourlyRate = 18.00
    Set walker2.Notes = "Veterinario con experiencia en comportamiento canino"
    Set walker2.Status = "Available"
    Do walker2.%Save()
    
    Set walker3 = ..%New()
    Set walker3.RUT = "17890165-4"
    Set walker3.Name = "Ana Martínez"
    Set walker3.Phone = "555-9012"
    Set walker3.Email = "ana.m@email.com"
    Set walker3.Age = 24
    Set walker3.Experience = 1
    Set walker3.Availability = "Tardes"
    Set walker3.HourlyRate = 12.00
    Set walker3.Notes = "Estudiante de veterinaria, ama los animales"
    Set walker3.Status = "Busy"
    Do walker3.%Save()
    
    Set walker4 = ..%New()
    Set walker4.RUT = "18901276-5"
    Set walker4.Name = "Luis Hernández"
    Set walker4.Phone = "555-3456"
    Set walker4.Email = "luis.h@email.com"
    Set walker4.Age = 42
    Set walker4.Experience = 8
    Set walker4.Availability = "Fines de semana"
    Set walker4.HourlyRate = 20.00
    Set walker4.Notes = "Entrenador profesional de perros, 8 años de experiencia"
    Set walker4.Status = "Available"
    Do walker4.%Save()
    
    Return $$$OK
}

/// Get walker by RUT
ClassMethod GetWalkerByRUT(rut As %String) As Demo.PETS.Walkers
{
    &sql(SELECT ID INTO :id FROM Demo_PETS.Walkers WHERE RUT = :rut)
    If SQLCODE = 0 {
        Return ..%OpenId(id)
    }
    Return ""
}

/// Get walker by ID
ClassMethod GetWalkerById(id As %Integer) As Demo.PETS.Walkers
{
    Return ..%OpenId(id)
}

/// Get available walkers
ClassMethod GetAvailableWalkers() As %ResultSet
{
    Set rs = ##class(%ResultSet).%New()
    Set rs.ClassName = "Demo.PETS.Walkers"
    Set rs.QueryName = "StatusQuery"
    Do rs.Execute("Available")
    Return rs
}

Query StatusQuery(status As %String) As %SQLQuery
{
    SELECT ID, Name, Phone, Age, Experience, Availability, HourlyRate, Status
    FROM Walkers
    WHERE Status = :status
    ORDER BY Name
}

Storage Default
{
<Data name="WalkersDefaultData">
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
<Value>Age</Value>
</Value>
<Value name="6">
<Value>Experience</Value>
</Value>
<Value name="7">
<Value>Availability</Value>
</Value>
<Value name="8">
<Value>HourlyRate</Value>
</Value>
<Value name="9">
<Value>References</Value>
</Value>
<Value name="10">
<Value>Status</Value>
</Value>
<Value name="11">
<Value>DateRegistered</Value>
</Value>
<Value name="12">
<Value>Notes</Value>
</Value>
<Value name="13">
<Value>RUT</Value>
</Value>
</Data>
<DataLocation>^Demo.PETS.WalkersD</DataLocation>
<DefaultData>WalkersDefaultData</DefaultData>
<ExtentSize>4</ExtentSize>
<IdLocation>^Demo.PETS.WalkersD</IdLocation>
<IndexLocation>^Demo.PETS.WalkersI</IndexLocation>
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
<Selectivity>25.0000%</Selectivity>
</Property>
<Property name="Availability">
<AverageFieldSize>12.75</AverageFieldSize>
<Selectivity>25.0000%</Selectivity>
</Property>
<Property name="DateRegistered">
<AverageFieldSize>2</AverageFieldSize>
<OutlierSelectivity>.999999:</OutlierSelectivity>
<Selectivity>0.0001%</Selectivity>
</Property>
<Property name="Email">
<AverageFieldSize>18</AverageFieldSize>
<Selectivity>25.0000%</Selectivity>
</Property>
<Property name="Experience">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>25.0000%</Selectivity>
</Property>
<Property name="HourlyRate">
<AverageFieldSize>5</AverageFieldSize>
<Selectivity>25.0000%</Selectivity>
</Property>
<Property name="Name">
<AverageFieldSize>16</AverageFieldSize>
<Selectivity>25.0000%</Selectivity>
</Property>
<Property name="Notes">
<AverageFieldSize>54</AverageFieldSize>
<Selectivity>25.0000%</Selectivity>
</Property>
<Property name="Phone">
<AverageFieldSize>10</AverageFieldSize>
<Selectivity>25.0000%</Selectivity>
</Property>
<Property name="Status">
<AverageFieldSize>9.75</AverageFieldSize>
<Selectivity>50.0000%</Selectivity>
</Property>
<SQLMap name="IDKEY">
<BlockCount>-4</BlockCount>
</SQLMap>
<StreamLocation>^Demo.PETS.WalkersS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
