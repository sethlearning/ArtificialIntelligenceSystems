function Import-OwlOntology
{
    Param(
        [string]$FileName,
        [string]$Url = "https://www.simplilearn.com/best-programming-languages-start-learning-today-article",
        [string]$SaveToFile
    )

    $ClassName = "Language"

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

            # Create new object
            $xml = New-Object -TypeName System.Xml.XmlDocument
            # Load XML file
            $xml.Load($path)

            # Get page content
            $response = Invoke-WebRequest -Uri $Url

            # Define pattern
            $pattern = '(?s)<article><h2 id="\d+.*?</article>'
            # If there are pattern matches
            if ($ms = Select-String -InputObject $response.Content -Pattern $pattern -AllMatches)
            {
                # Get articles
                $articles = $ms.Matches.Value

                # Pattern for tables
                $patterntable = '(?snx)<h2\sid.*?>\d+\.\s(?<Name>.+)</h2>.*?<table>.*?
                                 <p>Level:</p>\s?</td>\s?<td>\s?<p>(?<Level>.*?)</p>.*
                                 <p>Skills\sneeded:</p>\s?</td>\s?<td>\s?<p>(?<Skills>.*?)</p>.*?
                                 (<p>Platform:</p>\s?</td>\s?<td>\s?<p>(?<Platform>.*?)</p>.*)?
                                 ((<p>Popularity\sAmong\sProgrammers:</p>\s?</td>\s?<td>\s?<p>(?<PopularityAmongProgrammers>.*?)</p>.*)|(<p>Popularity\sAmong\sProgrammers:</p>\s?</td>\s?<td>\s?<ul>\s?(?<PopularityAmongProgrammers>.*?)\s?</ul>.*?))
                                 <p>Benefits:</p>\s?</td>\s?<td>\s?<ul>\s?(?<Benefits>.*?)\s?</ul>.*?
                                 ((<p>Downsides:</p>\s?</td>\s?<td>\s?<p>(?<Downsides>.*?)</p>\s?</td>.*)|(<p>Downsides:</p>\s?</td>\s?<td>\s?<ul>\s?(?<Downsides>.*?)\s?</ul>.*))?
                                 ((<p>Degree\sof\sUse:</p>\s?</td>\s?<td>\s?<p>(?<DegreeOfUse>.*?)</p>.*)|(<p>Degree\sof\sUse:</p>\s?</td>\s?<td>\s?<ul>\s?(?<DegreeOfUse>.*?)\s?</ul>.*))
                                 <p>Annual\sSalary\sProjection:</p>\s?</td>\s?<td>\s?<p>(?<AnnualSalaryProjection>.*?)</p>.*?
                                 </table>'
                # $patterntable1 = '(?snx)<h2\sid.*?>\d+\.\s(?<Name>.+)</h2>.*?<table>.*?
                # <p>Level:</p>\s?</td>\s?<td>\s?<p>(?<Level>.*?)</p>.*
                # <p>Skills\sneeded:</p>\s?</td>\s?<td>\s?<p>(?<Skills>.*?)</p>.*? # greedy any character
                # (<p>Platform:</p>\s?</td>\s?<td>\s?<p>(?<Platform>.*?)</p>.*)?
                # <p>Popularity\sAmong\sProgrammers:</p>\s?</td>\s?<td>\s?<p>(?<PopularityAmongProgrammers>.*?)</p>.*
                # <p>Benefits:</p>\s?</td>\s?<td>\s?<ul>\s?(?<Benefits>.*?)\s?</ul>.*? # greedy any character
                # (<p>Downsides:</p>\s?</td>\s?<td>\s?<p>(?<Downsides>.*?)</p>\s?</td>.*)?
                # <p>Degree\sof\sUse:</p>\s?</td>\s?<td>\s?<p>(?<DegreeOfUse>.*?)</p>.*
                # <p>Annual\sSalary\sProjection:</p>\s?</td>\s?<td>\s?<p>(?<AnnualSalaryProjection>.*?)</p>.*?
                # </table>'
                # $patterntable1 = '(?sx)<h2\sid.*?>\d+\.\s(?<Name>.+)</h2>.*?<table>.*?
                # <p>Level:</p>\s?</td>\s?<td>\s?<p>(?<Level>.*?)</p>.*
                # <p>Skills\sneeded:</p>\s?</td>\s?<td>\s?<p>(?<Skills>.*?)</p>.*
                # <p>Platform:</p>\s?</td>\s?<td>\s?<p>(?<Platform>.*?)</p>.*
                # <p>Popularity\sAmong\sProgrammers:</p>\s?</td>\s?<td>\s?<p>(?<PopularityAmongProgrammers>.*?)</p>.*
                # <p>Benefits:</p>\s?</td>\s?<td>\s?<ul>\s?(?<Benefits>.*?)\s?</ul>.*
                # <p>Downsides:</p>\s?</td>\s?<td>\s?<p>(?<Downsides>.*?)</p>\s?</td>.*
                # <p>Degree\sof\sUse:</p>\s?</td>\s?<td>\s?<p>(?<DegreeOfUse>.*?)</p>.*
                # <p>Annual\sSalary\sProjection:</p>\s?</td>\s?<td>\s?<p>(?<AnnualSalaryProjection>.*?)</p>.*?
                # </table>'
                # $patterntable1 = '(?sx)<h2\sid.*?>\d+\.\s(?<Name>.+)</h2>.*?<table>.*?
                # <p>Level:</p>\s?</td>\s?<td>\s?<p>(?<Level>.*?)</p>.*
                # <p>Skills\sneeded:</p>\s?</td>\s?<td>\s?<p>(?<Skills>.*?)</p>.*
                # <p>Platform:</p>\s?</td>\s?<td>\s?<p>(?<Platform>.*?)</p>.*
                # <p>Popularity\sAmong\sProgrammers:</p>\s?</td>\s?<td>\s?<p>(?<PopularityAmongProgrammers>.*?)</p>.*
                # <p>Benefits:</p>\s?</td>\s?<td>\s?<ul>\s?(?<Benefits>.*?)\s?</ul>.*
                # <p>Downsides:</p>\s?</td>\s?<td>\s?<p>(?<Downsides>.*?)</p>.*
                # <p>Degree\sof\sUse:</p>\s?</td>\s?<td>\s?<p>(?<DegreeOfUse>.*?)</p>.*
                # <p>Annual\sSalary\sProjection:</p>\s?</td>\s?<td>\s?<p>(?<AnnualSalaryProjection>.*?)</p>.*?
                # </table>'

                # Pattern for lists
                $patternul = '(?snx)<h2\sid.*?>\d+\.\s(?<Name>.+?)\s?</h2>.*?
                              <h3>Benefits.*?</h3>\s<ul>\s(?<Benefits>.*?)\s</ul>.*?
                              <h3>Con.*?</h3>.*?\s<ul>\s(?<Downsides>.*?)\s</ul>'
                # $patternul = '(?snx)<h2\sid.*?>\d+\.\s(?<Name>.+?)\s?</h2>.*?
                #               (?<Benefits><h3>Benefits.*?</ul>).*?
                #               (?<Cons><h3>Con.*?</ul>)'

                # For each article
                foreach ($article in $articles)
                {
                    # If article corresponds to table or list form
                    if (($ms = Select-String -InputObject $article -Pattern $patterntable) -or ($ms = Select-String -InputObject $article -Pattern $patternul))
                    {
                        # Instance name
                        $InstanceName = ($ms.Matches.Groups |
                                         Where-Object -Property Name -eq -Value 'Name' |
                                         Select-Object -ExpandProperty Value) `
                                         -replace '\s', '_' `
                                         -replace '#','S'

                        # Level
                        $Level = $ms.Matches.Groups |
                                 Where-Object -Property Name -eq -Value 'Level' |
                                 Select-Object -ExpandProperty Value

                        # Skills needed
                        $SkillsNeeded = $ms.Matches.Groups |
                                        Where-Object -Property Name -eq -Value 'Skills' |
                                        Select-Object -ExpandProperty Value

                        # Platform
                        $Platform = $ms.Matches.Groups |
                                    Where-Object -Property Name -eq -Value 'Platform' |
                                    Select-Object -ExpandProperty Value

                        # Popularity among programmers
                        $PopularityAmongProgrammers = ($ms.Matches.Groups |
                                                       Where-Object -Property Name -eq -Value 'PopularityAmongProgrammers' |
                                                       Select-Object -ExpandProperty Value) `
                                                       -replace '\s?</li>\n<li aria-level="1">','; ' `
                                                       -replace '<li aria-level="1">','' `
                                                       -replace '</li>',''

                        # Benefits
                        $Benefits = ($ms.Matches.Groups |
                                     Where-Object -Property Name -eq -Value 'Benefits' |
                                     Select-Object -ExpandProperty 'Value') `
                                     -replace '\s?</li>\n<li aria-level="1">','; ' `
                                     -replace '\s?</li>\n<li>','; ' `
                                     -replace '<li aria-level="1">','' `
                                     -replace '<li>','' `
                                     -replace '</li>','' `
                                     -replace ';;',';'

                        # Downsides
                        $Downsides = ($ms.Matches.Groups |
                                      Where-Object -Property Name -eq -Value 'Downsides' |
                                      Select-Object -ExpandProperty Value) `
                                      -replace '\s?</li>\n<li aria-level="1">','; ' `
                                      -replace '<li aria-level="1">','' `
                                      -replace '</li>','' `
                                      -replace '·\s+','' `
                                      -replace '</p>\n<p>','; '

                        # Degree of use
                        $DegreeOfUse = ($ms.Matches.Groups |
                                       Where-Object -Property Name -eq -Value 'DegreeOfUse' |
                                       Select-Object -ExpandProperty Value) `
                                       -replace '\s?</li>\n<li aria-level="1">','; ' `
                                       -replace '<li aria-level="1">','' `
                                       -replace '</li>',''

                        # Annual salary projections
                        $AnnualSalaryProjection = $ms.Matches.Groups |
                                                  Where-Object -Property Name -eq -Value AnnualSalaryProjection |
                                                  Select-Object -ExpandProperty Value

                        # Add instance
                        Write-Output -InputObject "Adding: $InstanceName"
                        inAddInstance -xml $xml -InstanceName $InstanceName -ClassName $ClassName

                        # Add data properties
                        if ($Level)
                        {
                            inAddDataPropertyAssertion -xml $xml -DataPropertyName Level -InstanceName $InstanceName -Value $Level
                        }
                        if ($SkillsNeeded)
                        {
                            inAddDataPropertyAssertion -xml $xml -DataPropertyName SkillsNeeded -InstanceName $InstanceName -Value $SkillsNeeded
                        }
                        if ($Platform) # Can be empty
                        {
                            inAddDataPropertyAssertion -xml $xml -DataPropertyName Platform -InstanceName $InstanceName -Value $Platform
                        }
                        if ($PopularityAmongProgrammers)
                        {
                            inAddDataPropertyAssertion -xml $xml -DataPropertyName PopularityAmongProgrammers -InstanceName $InstanceName -Value $PopularityAmongProgrammers
                        }
                        if ($Benefits)
                        {
                            inAddDataPropertyAssertion -xml $xml -DataPropertyName Benefits -InstanceName $InstanceName -Value $Benefits
                        }
                        if ($Downsides) # Can be empty
                        {
                            inAddDataPropertyAssertion -xml $xml -DataPropertyName Downsides -InstanceName $InstanceName -Value $Downsides
                        }
                        if ($DegreeOfUse)
                        {
                            inAddDataPropertyAssertion -xml $xml -DataPropertyName DegreeOfUse -InstanceName $InstanceName -Value $DegreeOfUse
                        }
                        if ($AnnualSalaryProjection)
                        {
                            inAddDataPropertyAssertion -xml $xml -DataPropertyName AnnualSalaryProjection -InstanceName $InstanceName -Value $AnnualSalaryProjection
                        }
                    }
                }

                # Save file
                $xml.Save($SaveToFile)
            }
            else
            {
                # Web page sturcture is different
                Write-Output -InputObject "Web page does not contain requested data"
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

function inAddInstance
{
    Param (
        [System.Xml.XmlDocument]$xml,
        [string]$InstanceName,
        [string]$ClassName
    )

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
            if ("#$ClassName" -cnotin $xml.Ontology.Declaration.Class.IRI)
            {
                Write-Output -InputObject "There are no such a class: $ClassName"
                return
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
            # Create ClassAssertion node
            $classassertion = $xml.CreateNode([System.Xml.XmlNodeType]::Element, "ClassAssertion", $xml.DocumentElement.NamespaceURI)

            # Create Class node
            $classnode = $xml.CreateNode([System.Xml.XmlNodeType]::Element, "Class", $xml.DocumentElement.NamespaceURI)
            # Set Class node attribute
            $classnode.SetAttribute("IRI", "#$ClassName")
            # Append Class node as a child to ClassAssertion node
            $classassertion.AppendChild($classnode) | Out-Null

            # Create NamedIndividual node
            $namedindividualnode = $xml.CreateNode([System.Xml.XmlNodeType]::Element, "NamedIndividual", $xml.DocumentElement.NamespaceURI)
            # Set NamedIndividual node attribute
            $namedindividualnode.SetAttribute("IRI", "#$InstanceName")
            # Append NamedIndividual node as a child to ClassAssertion node
            $classassertion.AppendChild($namedindividualnode) | Out-Null

            # Append ClassAssertion node as a child to Ontology node
            $xml.Ontology.AppendChild($classassertion) | Out-Null
        }
    }
}

function inAddDataPropertyAssertion
{
    Param (
        [System.Xml.XmlDocument]$xml,
        [ValidateSet('AnnualSalaryProjection', 'Benefits', 'DegreeOfUse', 'Downsides', 'Level', 'Platform', 'PopularityAmongProgrammers', 'SkillsNeeded')]
        [string]$DataPropertyName,
        [string]$InstanceName,
        [string]$Value
    )

    # If data property exists
    if ("#$DataPropertyName" -cin $xml.Ontology.Declaration.DataProperty.IRI)
    {
        # If instance exists
        if ("#$InstanceName" -cin $xml.Ontology.Declaration.NamedIndividual.IRI)
        {
            # Create DataPropertyAssertion node with default namespce URI
            $datapropertyassertion = $xml.CreateNode([System.Xml.XmlNodeType]::Element, "DataPropertyAssertion", $xml.DocumentElement.NamespaceURI)

            # Create DataProperty node with default namespace URI
            $dataproperty = $xml.CreateNode([System.Xml.XmlNodeType]::Element, "DataProperty", $xml.DocumentElement.NamespaceURI)
            # Set DataProperty node attribute
            $dataproperty.SetAttribute("IRI", "#$DataPropertyName")
            # Append DataProperty node as a child to DataPropertyAssertion node
            $datapropertyassertion.AppendChild($dataproperty) | Out-Null

            # Create NamedIndividual node with default namespace URI
            $namedindividual = $xml.CreateNode([System.Xml.XmlNodeType]::Element, "NamedIndividual", $xml.DocumentElement.NamespaceURI)
            # Set NamedIndividual node attribute
            $namedindividual.SetAttribute("IRI", "#$InstanceName")
            # Append NamedIndividual node as a child to DataPropertyAssertion node
            $datapropertyassertion.AppendChild($namedindividual) | Out-Null

            # Create Literal node
            $literal = $xml.CreateNode([System.Xml.XmlNodeType]::Element, "Literal", $xml.DocumentElement.NamespaceURI)
            # Add inner text to Literal node
            $literal.InnerText = $Value
            # Append Literal node as a child to DataPropertyAssertion node
            $datapropertyassertion.AppendChild($literal) | Out-Null

            # Append DataPropertyAssertion node as a child to Ontology node
            $xml.Ontology.AppendChild($datapropertyassertion) | Out-Null
        }
        else
        {
            Write-Output -InputObject "Instance does not exist: $InstanceName"
        }
    }
    else
    {
        Write-Output -InputObject "Data property does not exist: $DataPropertyName"
    }
}
