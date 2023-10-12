function Add-OwlInstanceAssociation
{
    Param (
        [string]$FileName,
        [string]$InstanceName,
        [string[]]$ClassName
    )

    # If FileName is specified
    if ($FileName)
    {
        # If path exists
        if ($path = Resolve-Path -Path $FileName -ErrorAction SilentlyContinue -ErrorVariable ea)
        {
            # Create new object
            $xml = New-Object -TypeName System.Xml.XmlDocument
            # Load XML file
            $xml.Load($path)

            # If instance exists
            if ("#$InstanceName" -in $xml.Ontology.Declaration.NamedIndividual.IRI)
            {
                # For each class name
                foreach ($class in $ClassName)
                {
                    # If class is exists
                    if ("#$class" -in $xml.Ontology.Declaration.Class.IRI)
                    {
                        # If the instance is not associated with the class
                        if (-not ($xml.Ontology.ClassAssertion |
                            Where-Object -Property NamedIndividual |
                            Where-Object -FilterScript {$PSItem.NamedIndividual.IRI -eq "#$InstanceName"} |
                            Where-Object -FilterScript {$PSItem.Class.IRI -eq "#$class"}))
                        {
                            # Create ClassAssertion node
                            $classassertion = $xml.CreateNode([System.Xml.XmlNodeType]::Element, "ClassAssertion", $xml.DocumentElement.NamespaceURI)
                            # Create Class node
                            $classnode = $xml.CreateNode([System.Xml.XmlNodeType]::Element, "Class", $xml.DocumentElement.NamespaceURI)
                            # Set Class node attribute
                            $classnode.SetAttribute("IRI", "#$class")
                            # Create NamedIndividual node
                            $namedindividualnode = $xml.CreateNode([System.Xml.XmlNodeType]::Element, "NamedIndividual", $xml.DocumentElement.NamespaceURI)
                            # Set NamedIndividual node attribute
                            $namedindividualnode.SetAttribute("IRI", "#$InstanceName")
                            # Append Class node as a child to ClassAssertion node
                            $classassertion.AppendChild($classnode) | Out-Null
                            # Append NamedIndividual node as a child to ClassAssertion node
                            $classassertion.AppendChild($namedindividualnode) | Out-Null
                            # Append ClassAssertion node as a child to Ontology node
                            $xml.Ontology.AppendChild($classassertion) | Out-Null

                            Write-Output -InputObject "Instance `"$InstanceName`" is now associated with the class `"$class`""
                        }
                        else
                        {
                            # Instance is already associated with the class
                            Write-Output -InputObject "Instance `"$InstanceName`" is already associated with the class `"$class`""
                        }
                    }
                    else
                    {
                        # Class is not exist
                        Write-Output -InputObject "Class `"$class`" is not exist"
                    }
                }
                # Save file
                $xml.Save($path)
            }
            else
            {
                # Instance is not found
                Write-Output -InputObject "There are no such an instance"
            }
        }
        else
        {
            # Resolve path error
            Write-Output -InputObject $ea.Exception.Message
        }
    }
    else
    {
        # FileName is not specified
        Write-Output -InputObject "File name is not specified"
    }
}

function Remove-OwlInstanceAssociation
{
    Param (
        [string]$FileName,
        [string]$InstanceName,
        [string[]]$ClassName
    )

    # If FileName is specified
    if ($FileName)
    {
        # If path exists
        if ($path = Resolve-Path -Path $FileName -ErrorAction SilentlyContinue -ErrorVariable ea)
        {
            # Create new object
            $xml = New-Object -TypeName System.Xml.XmlDocument
            # Load XML file
            $xml.Load($path)

            # If instance exists
            if ("#$InstanceName" -in $xml.Ontology.Declaration.NamedIndividual.IRI)
            {
                # For each class name
                foreach ($class in $ClassName)
                {
                    # If class is exists
                    if ("#$class" -in $xml.Ontology.Declaration.Class.IRI)
                    {
                        # If the instance is associated with the class
                        if ($node = $xml.Ontology.ClassAssertion |
                            Where-Object -Property NamedIndividual |
                            Where-Object -FilterScript {$PSItem.NamedIndividual.IRI -eq "#$InstanceName"} |
                            Where-Object -FilterScript {$PSItem.Class.IRI -eq "#$class"})
                        {
                            # Remove ClassAssociation from Ontology node
                            $xml.Ontology.RemoveChild($node) | Out-Null
                            Write-Output -InputObject "Instance `"$InstanceName`" is now dissociated from the class `"$class`""
                        }
                        else
                        {
                            # Instance is not associated with the class
                            Write-Output -InputObject "Instance `"$InstanceName`" is not associated with the class `"$class`""
                        }
                    }
                    else
                    {
                        # Class is not exist
                        Write-Output -InputObject "Class `"$class`" is not exist"
                    }
                }
                # Save file
                $xml.Save($path)
            }
            else
            {
                # Instance is not found
                Write-Output -InputObject "There are no such an instance"
            }
        }
        else
        {
            # Resolve path error
            Write-Output -InputObject $ea.Exception.Message
        }
    }
    else
    {
        # FileName is not specified
        Write-Output -InputObject "File name is not specified"
    }
}

function Set-OwlInstanceAssociation
{
    Param (
        [string]$FileName,
        [string]$InstanceName,
        [string[]]$ClassName
    )

    # If FileName is specified
    if ($FileName)
    {
        # If path exists
        if ($path = Resolve-Path -Path $FileName -ErrorAction SilentlyContinue -ErrorVariable ea)
        {
            # Create new object
            $xml = New-Object -TypeName System.Xml.XmlDocument
            # Load XML file
            $xml.Load($path)

            # If instance exists
            if ("#$InstanceName" -in $xml.Ontology.Declaration.NamedIndividual.IRI)
            {
                # If the instance is associated with classes other than the specified
                if ($nodes = $xml.Ontology.ClassAssertion |
                             Where-Object -Property NamedIndividual |
                             Where-Object -FilterScript {$PSItem.NamedIndividual.IRI -eq "#$InstanceName"} |
                             Where-Object -FilterScript {$PSItem.Class.IRI -notin
                                ($ClassName | Where-Object -FilterScript {$PSItem} |
                                 ForEach-Object -Process {$PSItem.Insert(0,'#')})})
                {
                    # For each such class
                    foreach ($node in $nodes)
                    {
                        # Remove ClassAssertion from Ontology node
                        $xml.Ontology.RemoveChild($node) | Out-Null
                        Write-Output -InputObject "Removed association with class: $($node.Class.IRI.Trim('#'))"
                    }

                }

                foreach ($class in $ClassName)
                {
                    # If class is exists
                    if ("#$class" -in $xml.Ontology.Declaration.Class.IRI)
                    {
                        # If the instance is not associated with the class
                        if (-not ($xml.Ontology.ClassAssertion |
                            Where-Object -Property NamedIndividual |
                            Where-Object -FilterScript {$PSItem.NamedIndividual.IRI -eq "#$InstanceName"} |
                            Where-Object -FilterScript {$PSItem.Class.IRI -eq "#$class"}))
                        {
                            # Create ClassAssertion node
                            $classassertion = $xml.CreateNode([System.Xml.XmlNodeType]::Element, "ClassAssertion", $xml.DocumentElement.NamespaceURI)
                            # Create Class node
                            $classnode = $xml.CreateNode([System.Xml.XmlNodeType]::Element, "Class", $xml.DocumentElement.NamespaceURI)
                            # Set Class node attribute
                            $classnode.SetAttribute("IRI", "#$class")
                            # Create NamedIndividual node
                            $namedindividualnode = $xml.CreateNode([System.Xml.XmlNodeType]::Element, "NamedIndividual", $xml.DocumentElement.NamespaceURI)
                            # Set NamedIndividual node attribute
                            $namedindividualnode.SetAttribute("IRI", "#$InstanceName")
                            # Append Class node as a child to ClassAssertion node
                            $classassertion.AppendChild($classnode) | Out-Null
                            # Append NamedIndividual node as a child to ClassAssertion node
                            $classassertion.AppendChild($namedindividualnode) | Out-Null
                            # Append ClassAssertion node as a child to Ontology node
                            $xml.Ontology.AppendChild($classassertion) | Out-Null

                            Write-Output -InputObject "Added association with class: $class"
                        }
                        else
                        {
                            # Instance is already associated with the class
                            Write-Output -InputObject "Already associated with class: $class"
                        }
                    }
                    else
                    {
                        # Class is not exist
                        Write-Output -InputObject "Class is not exist: $class"
                    }
                }
                # Save file
                $xml.Save($path)
            }
            else
            {
                # Instance is not found
                Write-Output -InputObject "There are no such an instance"
            }
        }
        else
        {
            # Resolve path error
            Write-Output -InputObject $ea.Exception.Message
        }
    }
    else
    {
        # FileName is not specified
        Write-Output -InputObject "File name is not specified"
    }
}
