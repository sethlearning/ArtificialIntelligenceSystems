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

    # Resolve path
    $path = Resolve-Path -Path $FileName -ErrorAction SilentlyContinue -ErrorVariable ea

    # If path exists
    if ($path)
    {
        # Create new object
        $xml = New-Object -TypeName System.Xml.XmlDocument
        # Load XML file
        $xml.Load($path)

        switch ($Entity)
        {
            # Get class list
            'class'
            {
                $xml.Ontology.Declaration.Class.IRI.Trim('#')
            }
            # Get instance list
            'instance'
            {
                $xml.Ontology.Declaration.NamedIndividual.IRI.Trim('#')
            }
        }
    }
    else
    {
        # Resolve path error
        Write-Output -InputObject $ea.Exception.Message
    }
}

function New-OwlClass
{
    Param(
        [string]$FileName,
        [string]$ClassName
    )

    # Resolve path
    $path = Resolve-Path -Path $FileName -ErrorAction SilentlyContinue -ErrorVariable ea

    # If path exists
    if ($path)
    {
        # Create new object
        $xml = New-Object -TypeName System.Xml.XmlDocument
        # Load XML file
        $xml.Load($path)

        # If class exists
        if ($ClassName -in $xml.Ontology.Declaration.Class.IRI.Trim('#'))
        {
            Write-Output -InputObject "The class is already exist"
        }
        else
        {
            # Create Declaration node with default namespace URI
            $declaration = $xml.CreateNode([System.Xml.XmlNodeType]::Element, "Declaration", $xml.DocumentElement.NamespaceURI)
            
            # Create Class node with default namespace URI
            $class = $xml.CreateNode([System.Xml.XmlNodeType]::Element, "Class", $xml.DocumentElement.NamespaceURI)

            # Set Class node attribute
            $class.SetAttribute("IRI", "#" + $ClassName)

            # Append Class node as child to Declaration node
            $declaration.AppendChild($class) | Out-Null

            # Append Declaration node as child to Ontology node
            $xml.Ontology.AppendChild($declaration) | Out-Null

            # Save file
            $xml.Save($path)
        }

    }
    else
    {
        # Resolve path error
        Write-Output -InputObject $ea.Exception.Message
    }
}

function Remove-OwlClass
{
    Param(
        [string]$FileName,
        [string]$ClassName
    )

    # Resolve path
    $path = Resolve-Path -Path $FileName -ErrorAction SilentlyContinue -ErrorVariable ea

    # If path exists
    if ($path)
    {
        # Create new object
        $xml = New-Object -TypeName System.Xml.XmlDocument
        # Load XML file
        $xml.Load($path)

        # If class exists
        if ($ClassName -in $xml.Ontology.Declaration.Class.IRI.Trim('#'))
        {
            # If class is associated with another elements (so we cannot remove it directly)
            if ($ClassName -in $xml.Ontology.ClassAssertion.Class.IRI.Trim('#') -or
                $ClassName -in $xml.Ontology.DataPropertyDomain.Class.IRI.Trim('#') )
            {
                Write-Output -InputObject "Class is associated with another ontology elements"
            }
            else
            {
                # Get class declaration node
                $node = $xml.Ontology.Declaration | Where-Object -Property "Class" | Where-Object -FilterScript { $PSItem.Class.IRI.Trim('#') -eq $ClassName}
                # Remove class declaration node from children of Ontology node
                $xml.Ontology.RemoveChild($node) | Out-Null
                # Save file
                $xml.Save($path)
            }
        }
        else
        {
            # Class is not found
            Write-Output -InputObject "There are no such a class"
        }
    }
    else
    {
        # Resolve path error
        Write-Output -InputObject $ea.Exception.Message
    }
}
