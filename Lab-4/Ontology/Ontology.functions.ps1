function Get-OwlClass
{
    Param([string]$FileName)

    inGet -Filename $FileName -Entity 'class'
}

function Get-OwlInstance
{
    Param([string]$FileName)
    
    inGet -Filename $FileName -Entity 'instance'
}

function inGet
{
    Param(
        [string]$FileName,
        [string]$Entity
    )

    $path = Resolve-Path -Path $FileName -ErrorAction SilentlyContinue -ErrorVariable ea

    if ($path)
    {
        $xml = New-Object -TypeName System.Xml.XmlDocument
        $xml.Load($path)

        switch ($Entity)
        {
            'class'
            {
                $xml.Ontology.Declaration.Class.IRI.Trim('#')
            }
            'instance'
            {
                $xml.Ontology.Declaration.NamedIndividual.IRI.Trim('#')
            }
        }
    }
    else
    {
        Write-Output -InputObject $ea.Exception.Message
    }
}

function New-OwlClass
{
    Param(
        [string]$FileName,
        [string]$ClassName
    )

    $path = Resolve-Path -Path $FileName -ErrorAction SilentlyContinue -ErrorVariable ea

    if ($path)
    {
        $xml = New-Object -TypeName System.Xml.XmlDocument
        $xml.Load($path)

        if ($ClassName -in $xml.Ontology.Declaration.Class.IRI.Trim('#'))
        {
            Write-Output -InputObject "There is already"
        }
        else
        {
            # $declaration = $xml.CreateNode([System.Xml.XmlNodeType]::Element, "owl", "Declaration", "http://www.w3.org/2002/07/owl#")
            # $declaration = $xml.CreateNode([System.Xml.XmlNodeType]::Element, "owl", "Declaration", $null)
            # $declaration = $xml.CreateNode([System.Xml.XmlNodeType]::Element, "owl", "Declaration", $xml.DocumentElement.NamespaceURI)
            $declaration = $xml.CreateNode([System.Xml.XmlNodeType]::Element, "Declaration", $xml.DocumentElement.NamespaceURI)
            
            # $class = $xml.CreateNode([System.Xml.XmlNodeType]::Element, "owl", "Class", $null)
            $class = $xml.CreateNode([System.Xml.XmlNodeType]::Element, "Class", $xml.DocumentElement.NamespaceURI)

            $class.SetAttribute("IRI", "#" + $ClassName)

            # $class.AppendChild($iri)
            $declaration.AppendChild($class)
            $xml.Ontology.AppendChild($declaration)

            $xml.Save($path)
        }

    }
    else
    {
        Write-Output -InputObject $ea.Exception.Message
    }
}
