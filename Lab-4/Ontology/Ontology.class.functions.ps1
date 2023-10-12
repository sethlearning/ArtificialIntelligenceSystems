function Get-OwlClass
{
    Param([string]$FileName)

    # Resolve path
    $path = Resolve-Path -Path $FileName -ErrorAction SilentlyContinue -ErrorVariable ea

    # If path exists
    if ($path)
    {
        # Create new object
        $xml = New-Object -TypeName System.Xml.XmlDocument
        # Load XML file
        $xml.Load($path)

        # Define array of result objects
        $classlist = @()

        # Create objects with ClassName property
        foreach ($class in $xml.Ontology.Declaration.Class.IRI)
        {
            $classlist += [pscustomobject]@{ClassName = $class.Trim("#")}
        }

        # If there are class hierarchy
        if ($xml.Ontology.SubClassOf)
        {
            # For each object in the result array
            foreach ($class in $classlist)
            {
                # Find corresponding SubClassOf node
                if ($node = $xml.Ontology.SubClassOf | Where-Object -Property Class | Where-Object -FilterScript {$PSItem.Class[0].IRI -eq "#$($class.ClassName)"})
                {
                    # Add Parent property with parent class name
                    $class | Add-Member -MemberType NoteProperty -Name Parent -Value $node.Class[1].IRI.Trim('#')
                }
                else
                {
                    # Add parent property with the "Top" value
                    $class | Add-Member -MemberType NoteProperty -Name Parent -Value "Top"
                }
            }
        }

        $classlist
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
        [string]$ClassName,
        [string]$ParentClassName
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
        if ("#$ClassName" -in $xml.Ontology.Declaration.Class.IRI)
        {
            Write-Output -InputObject "The class is already exist"
        }
        else
        {
            # If Parent class name is specified and there are no such a class
            if ($ParentClassName -and "#$ParentClassName" -notin $xml.Ontology.Declaration.Class.IRI)
            {
                Write-Output -InputObject "There are no such a parent class"
                return
            }

            # Create Declaration node with default namespace URI
            $declaration = $xml.CreateNode([System.Xml.XmlNodeType]::Element, "Declaration", $xml.DocumentElement.NamespaceURI)
            
            # Create Class node with default namespace URI
            $class = $xml.CreateNode([System.Xml.XmlNodeType]::Element, "Class", $xml.DocumentElement.NamespaceURI)

            # Set Class node attribute
            $class.SetAttribute("IRI", "#" + $ClassName)

            # Append Class node as a child to Declaration node
            $declaration.AppendChild($class) | Out-Null

            # Append Declaration node as a child to Ontology node
            $xml.Ontology.AppendChild($declaration) | Out-Null

            if ($ParentClassName)
            {
                # Create SubClassOf node
                $subclassof = $xml.CreateNode([System.Xml.XmlNodeType]::Element, "SubClassOf", $xml.DocumentElement.NamespaceURI)
                # Create child Class node
                $childclass = $xml.CreateNode([System.Xml.XmlNodeType]::Element, "Class", $xml.DocumentElement.NamespaceURI)
                # Set child Class node attribute
                $childclass.SetAttribute("IRI", "#" + $ClassName)
                # Create parent Class node
                $parentclass = $xml.CreateNode([System.Xml.XmlNodeType]::Element, "Class", $xml.DocumentElement.NamespaceURI)
                # Set parent Class node attribute
                $parentclass.SetAttribute("IRI", "#" + $ParentClassName)
                # Append child Class node as a child to SubClassOf node
                $subclassof.AppendChild($childclass) | Out-Null
                # Append parent Class node as a child to SubClassOf node
                $subclassof.AppendChild($parentclass) | Out-Null
                # Append SubClassOf node as a child to Ontology node
                $xml.Ontology.AppendChild($subclassof) | Out-Null
            }

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
        if ("#$ClassName" -in $xml.Ontology.Declaration.Class.IRI)
        {
                # If there are objects of the class
            if ("#$ClassName" -in $xml.Ontology.ClassAssertion.Class.IRI -or
                # If there are data properties with domain of the class
                "#$ClassName" -in $xml.Ontology.DataPropertyDomain.Class.IRI -or
                # If the class is parent to another class
                ($xml.Ontology.SubClassOf | Where-Object -Property Class | Where-Object -FilterScript {$PSItem.Class[1].IRI -eq "#$ClassName"}) )
            {
                Write-Output -InputObject "Class is associated with another ontology elements"
            }
            else
            {
                # If the class is a child of another class
                if ($node = $xml.Ontology.SubClassOf | Where-Object -Property Class | Where-Object -FilterScript {$PSItem.Class[0].IRI -eq "#$ClassName"})
                {
                    # Remove class parent-child relationship node from Ontology node
                    $xml.Ontology.RemoveChild($node) | Out-Null
                }

                # Get class declaration node
                $node = $xml.Ontology.Declaration | Where-Object -Property "Class" | Where-Object -FilterScript {$PSItem.Class.IRI -eq "#$ClassName"}
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

function Rename-OwlClass
{
    Param(
        [string]$FileName,
        [string]$ClassName,
        [string]$NewClassName
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
        if ($node = $xml.Ontology.Declaration.Class | Where-Object -Property IRI -eq -Value "#$ClassName")
        {
            # Rename class
            $node.SetAttribute("IRI", "#$NewClassName")

            # If the class is a child of another class
            if ($nodes = $xml.Ontology.SubClassOf |
                            Where-Object -Property Class |
                            Where-Object -FilterScript {$PSItem.Class[0].IRI -eq "#$ClassName"} |
                            ForEach-Object -Process {$PSItem.Class[0]})
            {
                foreach ($node in $nodes)
                {
                    # Rename class in SubClassOf node
                    $node.SetAttribute("IRI", "#$NewClassName")
                }
            }

            # If the class is a parent to another class
            if ($nodes = $xml.Ontology.SubClassOf |
                            Where-Object -Property Class |
                            Where-Object -FilterScript {$PSItem.Class[1].IRI -eq "#$ClassName"} |
                            ForEach-Object -Process {$PSItem.Class[1]})
            {
                foreach ($node in $nodes)
                {
                    # Rename class in SubClassOf node
                    $node.SetAttribute("IRI", "#$NewClassName")
                }
            }

            # If there are objects of the class
            if ($nodes = $xml.Ontology.ClassAssertion |
                            Where-Object -Property Class |
                            Where-Object -FilterScript {$PSItem.Class.IRI -eq "#$ClassName"} |
                            ForEach-Object -Process {$PSItem.Class})
            {
                foreach ($node in $nodes)
                {
                    # Rename class in ClassAssertion node
                    $node.SetAttribute("IRI", "#$NewClassName")
                }
            }

            # If there are data properties with domain of the class
            if ($nodes = $xml.Ontology.DataPropertyDomain |
                            Where-Object -Property Class |
                            Where-Object -FilterScript {$PSItem.Class.IRI -eq "#$ClassName"} |
                            ForEach-Object -Process {$PSItem.Class})
            {
                foreach ($node in $nodes)
                {
                    # Rename class in DataPropertyDomain node
                    $node.SetAttribute("IRI", "#$NewClassName")
                }
            }
            # Save file
            $xml.Save($path)
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
