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
            Write-Output -InputObject "The class is already present"
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
            $declaration.AppendChild($class) | Out-Null
            $xml.Ontology.AppendChild($declaration) | Out-Null

            $xml.Save($path)
        }

    }
    else
    {
        Write-Output -InputObject $ea.Exception.Message
    }
}

function Remove-OwlClass
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
<#
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
            $declaration.AppendChild($class) | Out-Null
            $xml.Ontology.AppendChild($declaration) | Out-Null

            $xml.Save($path)
        }
#>
        if ($ClassName -in $xml.Ontology.Declaration.Class.IRI.Trim('#'))
        {
            if ($ClassName -in $xml.Ontology.ClassAssertion.Class.IRI.Trim('#') -or
                $ClassName -in $xml.Ontology.DataPropertyDomain.Class.IRI.Trim('#') )
            {
                Write-Output -InputObject "Class is associated with another ontology elements"
            }
            else
            {
                $node = $xml.Ontology.Declaration | Where-Object -Property "Class" | Where-Object -FilterScript { $PSItem.Class.IRI.Trim('#') -eq $ClassName}
                # Write-Output -InputObject $node.Class.IRI
                $xml.Ontology.RemoveChild($node) | Out-Null
                # $node
                $xml.Save($path)
            }
        }
        else
        {
            Write-Output -InputObject "There are no such a class"
        }
    }
    else
    {
        Write-Output -InputObject $ea.Exception.Message
    }
}
