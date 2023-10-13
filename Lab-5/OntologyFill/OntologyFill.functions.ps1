function Import-OwlOntology
{
    Param(
        [string]$FileName,
        [string]$Url = "https://www.simplilearn.com/best-programming-languages-start-learning-today-article"
    )

    $ClassName = "Language"

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

            # Get page content
            $response = Invoke-WebRequest -Uri $Url

            # Define pattern
            $pattern = '(?s)<article><h2 id="\d+.*?</article>'
            # If there are pattern matches
            if ($ms = Select-String -InputObject $response.Content -Pattern $pattern -AllMatches)
            {
                # Get articles
                $articles = $ms.Matches.Value

                $patterntable1 = '(?sx)<h2\sid.*?>\d+\.\s(?<Name>.+)</h2>.*?<table>.*?
                <p>Level:</p>\s?</td>\s?<td>\s?<p>(?<Level>.*?)</p>.*
                <p>Skills\sneeded:</p>\s?</td>\s?<td>\s?<p>(?<Skills>.*?)</p>.*
                <p>Platform:</p>\s?</td>\s?<td>\s?<p>(?<Platform>.*?)</p>.*
                <p>Popularity\sAmong\sProgrammers:</p>\s?</td>\s?<td>\s?<p>(?<PopularityAmongProgrammers>.*?)</p>.*
                <p>Benefits:</p>\s?</td>\s?<td>\s?<ul>\s?(?<Benefits>.*?)\s?</ul>.*
                <p>Downsides:</p>\s?</td>\s?<td>\s?<p>(?<Downsides>.*?)</p>\s?</td>.*
                <p>Degree\sof\sUse:</p>\s?</td>\s?<td>\s?<p>(?<DegreeOfUse>.*?)</p>.*
                <p>Annual\sSalary\sProjection:</p>\s?</td>\s?<td>\s?<p>(?<AnnualSalaryProjection>.*?)</p>.*?
                </table>'
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
                $patternul = '(?s)<h2 id.*?>\d+\. (?<Name>.+?)\s?</h2>.*?(?<Benefits><h3>Benefits.*?</ul>).*?(?<Cons><h3>Con.*?</ul>)'

                # For each article
                foreach ($article in $articles)
                {
                    # If contains table form 1
                    if ($ms = Select-String -InputObject $article -Pattern $patterntable1)
                    {
                        # Instance name
                        $InstanceName = $ms.Matches.Groups[1].Value -replace '\s', '_' -replace '#','S'
                        Write-Output -InputObject "Adding: $InstanceName"
                        inAddInstance -xml $xml -InstanceName $InstanceName -ClassName $ClassName
                        
                        # Level
                        $Level = $ms.Matches.Groups[2].Value
                        inAddDataPropertyAssertion -xml $xml -DataPropertyName Level -InstanceName $InstanceName -Value $Level
                        
                        # Skills needed
                        $SkillsNeeded = $ms.Matches.Groups[3].Value
                        inAddDataPropertyAssertion -xml $xml -DataPropertyName SkillsNeeded -InstanceName $InstanceName -Value $SkillsNeeded

                        # Platform
                        $Platform = $ms.Matches.Groups[4].Value
                        inAddDataPropertyAssertion -xml $xml -DataPropertyName Platform -InstanceName $InstanceName -Value $Platform

                        # Popularity among programmers
                        $PopularityAmongProgrammers = $ms.Matches.Groups[5].Value
                        inAddDataPropertyAssertion -xml $xml -DataPropertyName PopularityAmongProgrammers -InstanceName $InstanceName -Value $PopularityAmongProgrammers

                        # Benefits
                        $Benefits = $ms.Matches.Groups[6].Value -replace '\s?</li>\n<li aria-level="1">','; ' -replace '\s?</li>\n<li>','; ' -replace '<li aria-level="1">','' -replace '<li>','' -replace '</li>','' -replace ';;',';'
                        inAddDataPropertyAssertion -xml $xml -DataPropertyName Benefits -InstanceName $InstanceName -Value $Benefits

                        # Downsides
                        $Downsides = $ms.Matches.Groups[7].Value -replace '·\s+','' -replace '</p>\n<p>','; '
                        inAddDataPropertyAssertion -xml $xml -DataPropertyName Downsides -InstanceName $InstanceName -Value $Downsides

                        # Degree of use
                        $DegreeOfUse = $ms.Matches.Groups[8].Value
                        inAddDataPropertyAssertion -xml $xml -DataPropertyName DegreeOfUse -InstanceName $InstanceName -Value $DegreeOfUse

                        # Annual salary projections
                        $AnnualSalaryProjection = $ms.Matches.Groups[9].Value
                        inAddDataPropertyAssertion -xml $xml -DataPropertyName AnnualSalaryProjection -InstanceName $InstanceName -Value $AnnualSalaryProjection

                    }
                    # If does not contain table
                    # elseif ($ms = Select-String -InputObject $article -Pattern $patternul)
                    # {
                    #     $InstanceName = $ms.Matches.Groups[1].Value -replace '\s', '_' -replace '#','S'
                    #     Write-Output -InputObject "Adding: $InstanceName"
                    #     inAddInstance -xml $xml -InstanceName $InstanceName -ClassName $ClassName
                    # }
                }

                # Save file
                $xml.Save("C:\t.xml")
            }
            else
            {
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
