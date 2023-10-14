function Get-OwlInstance
{
    Param([string]$FileName)

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

            # Define array of result objects
            $instancelist = @()

            foreach ($instance in $xml.Ontology.Declaration.NamedIndividual.IRI)
            {
                $instancelist += [pscustomobject]@{InstanceName = $instance.Trim('#')}
            }

            # If there are class hierarchy
            if ($xml.Ontology.Declaration.Class)
            {
                # For each object in the result array
                foreach ($instance in $instancelist)
                {
                    # Create empty classnames array
                    $classnames = @()
                    # Find corresponding ClassAssertion nodes
                    if ($nodes = $xml.Ontology.ClassAssertion |
                                Where-Object -Property NamedIndividual |
                                Where-Object -FilterScript {$PSItem.NamedIndividual.IRI -ceq "#$($instance.InstanceName)"})
                    {
                        # For each corresponding ClassAssertion node
                        foreach ($node in $nodes)
                        {
                            # Add classname to array
                            $classnames += $node.Class.IRI.Trim('#')
                        }
                    }
                    # Add classnames array as Class property to object (empty array if the instance is not assigned to any class)
                    $instance | Add-Member -MemberType NoteProperty -Name Class -Value $classnames
                }
            }
            $instancelist
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

function New-OwlInstance
{
    Param (
        [string]$FileName,
        [string]$InstanceName,
        [string[]]$ClassName,
        [string]$SaveToFile
    )

    # If FileName is specified
    if ($FileName)
    {
        # If path exists
        if ($path = Resolve-Path -Path $FileName -ErrorAction SilentlyContinue -ErrorVariable ea)
        {
            # Save to a different file
            if ($SaveToFile)
            {
                # If path is relative
                if (-not (Split-Path -Path $SaveToFile -IsAbsolute))
                {
                    # Add to the current location
                    $SaveToFile = Join-Path -Path $PWD.Path -ChildPath $SaveToFile
                }
            }
            # Save to the same file
            else
            {
                $SaveToFile = $path
            }

            # If InstanceName is specified
            if ($InstanceName)
            {
                # Create new object
                $xml = New-Object -TypeName System.Xml.XmlDocument
                # Load XML file
                $xml.Load($path)

                # If instance exists
                if ("#$InstanceName" -cin $xml.Ontology.Declaration.NamedIndividual.IRI)
                {
                    Write-Output -InputObject "The instance is already exists"
                }
                else
                {
                    # If ClassName is specified and there are no such a class
                    if ($ClassName)
                    {
                        foreach ($class in $ClassName)
                        {
                            if ("#$class" -cnotin $xml.Ontology.Declaration.Class.IRI)
                            {
                                Write-Output -InputObject "Class does not exist: $class"
                                return
                            }
                        }
                    }

                    # Create Declaration node with default namespace URI
                    $declaration = $xml.CreateNode([System.Xml.XmlNodeType]::Element, "Declaration", $xml.DocumentElement.NamespaceURI)

                    # Create NamedIndividual node with default namespace URI
                    $namedindividual = $xml.CreateNode([System.Xml.XmlNodeType]::Element, "NamedIndividual", $xml.DocumentElement.NamespaceURI)

                    # Set NamedIndividual node attribute
                    $namedindividual.SetAttribute("IRI", "#$InstanceName")

                    # Append NamedIndividual node as a child to Declaration node
                    $declaration.AppendChild($namedindividual) | Out-Null

                    # Append Declaration node as a child to Ontology node
                    $xml.Ontology.AppendChild($declaration) | Out-Null

                    if ($ClassName)
                    {
                        foreach ($class in $ClassName)
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
                        }
                    }

                    # Save file
                    $xml.Save($SaveToFile)
                }
            }
            else
            {
                # InstanceName is not specified
                Write-Output -InputObject "Instance name is not specified"
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

function Remove-OwlInstance
{
    Param (
        [string]$FileName,
        [string]$InstanceName,
        [string]$SaveToFile
    )

    # If FileName is specified
    if ($FileName)
    {
        # If path exists
        if ($path = Resolve-Path -Path $FileName -ErrorAction SilentlyContinue -ErrorVariable ea)
        {
            # Save to a different file
            if ($SaveToFile)
            {
                # If path is relative
                if (-not (Split-Path -Path $SaveToFile -IsAbsolute))
                {
                    # Add to the current location
                    $SaveToFile = Join-Path -Path $PWD.Path -ChildPath $SaveToFile
                }
            }
            # Save to the same file
            else
            {
                $SaveToFile = $path
            }

            # If InstanceName is specified
            if ($InstanceName)
            {
                # Create new object
                $xml = New-Object -TypeName System.Xml.XmlDocument
                # Load XML file
                $xml.Load($path)

                # If instance exists
                if ("#$InstanceName" -cin $xml.Ontology.Declaration.NamedIndividual.IRI)
                {
                    # If there are properties associated with the instance
                    if ("#$InstanceName" -cin $xml.Ontology.DataPropertyAssertion.NamedIndividual.IRI)
                    {
                        Write-Output -InputObject "There are properties associated with the instance"
                    }
                    else
                    {
                        # If the instance is associated with classes
                        if ($nodes = $xml.Ontology.ClassAssertion | Where-Object -Property NamedIndividual | Where-Object -FilterScript {$PSItem.NamedIndividual.IRI -ceq "#$InstanceName"})
                        {
                            # For each association
                            foreach ($node in $nodes)
                            {
                                # Remove ClassAssociation from Ontology node
                                $xml.Ontology.RemoveChild($node) | Out-Null
                            }
                        }

                        # Get instance declaration node
                        $node = $xml.Ontology.Declaration | Where-Object -Property NamedIndividual | Where-Object -FilterScript {$PSItem.NamedIndividual.IRI -ceq "#$InstanceName"}
                        # Remove instance declaration node from children of Ontology node
                        $xml.Ontology.RemoveChild($node) | Out-Null
                        # Save file
                        $xml.Save($SaveToFile)
                    }
                }
                else
                {
                    # Instance is not found
                    Write-Output -InputObject "Instance does not exist: $InstanceName"
                }
            }
            else
            {
                # InstanceName is not specified
                Write-Output -InputObject "Instance name is not specified"
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

function Rename-OwlInstance
{
    Param (
        [string]$FileName,
        [string]$InstanceName,
        [string]$NewInstanceName,
        [string]$SaveToFile
    )

    # If FileName is specified
    if ($FileName)
    {
        # If path exists
        if ($path = Resolve-Path -Path $FileName -ErrorAction SilentlyContinue -ErrorVariable ea)
        {
            # Save to a different file
            if ($SaveToFile)
            {
                # If path is relative
                if (-not (Split-Path -Path $SaveToFile -IsAbsolute))
                {
                    # Add to the current location
                    $SaveToFile = Join-Path -Path $PWD.Path -ChildPath $SaveToFile
                }
            }
            # Save to the same file
            else
            {
                $SaveToFile = $path
            }

            # If InstanceName is specified
            if ($InstanceName)
            {
                # Create new object
                $xml = New-Object -TypeName System.Xml.XmlDocument
                # Load XML file
                $xml.Load($path)

                # If instance exists
                if ($node = $xml.Ontology.Declaration.NamedIndividual | Where-Object -Property IRI -ceq -Value "#$InstanceName")
                {
                    # If NewInstanceName is specified
                    if ($NewInstanceName)
                    {
                        # Rename instance
                        $node.SetAttribute("IRI", "#$NewInstanceName")
                        
                        # If the instance is associated with classes
                        if ($nodes = $xml.Ontology.ClassAssertion |
                                    Where-Object -Property NamedIndividual |
                                    Where-Object -FilterScript {$PSItem.NamedIndividual.IRI -ceq "#$InstanceName"} |
                                    ForEach-Object -MemberName NamedIndividual)
                        {
                            foreach($node in $nodes)
                            {
                                # Rename instance in ClassAssertion node
                                $node.SetAttribute("IRI", "#$NewInstanceName")
                            }
                        }

                        # If there are properties associated with the instance
                        if ($nodes = $xml.Ontology.DataPropertyAssertion |
                                    Where-Object -Property NamedIndividual |
                                    Where-Object -FilterScript {$PSItem.NamedIndividual.IRI -ceq "#$InstanceName"} |
                                    ForEach-Object -MemberName NamedIndividual)
                        {
                            foreach ($node in $nodes)
                            {
                                # Rename instance in DataPropertyAssertion node
                                $node.SetAttribute("IRI", "#$NewInstanceName")
                            }
                        }

                        # Save file
                        $xml.Save($SaveToFile)
                    }
                    else
                    {
                        # NewInstanceName is not specified
                        Write-Output -InputObject "New instance name is not specified"
                    }
                }
                else
                {
                    # Instance is not found
                    Write-Output -InputObject "Instance does not exist: $InstanceName"
                }
            }
            else
            {
                # InstanceName is not specified
                Write-Output -InputObject "Instance name is not specified"
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
