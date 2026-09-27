program DijkstraAlgoritmo;  
  
{ 
  +---------------------------------------------+
	|PROIBIcoES DO BASTOS:                        |
	| - S/ Break e Exit;                          |
	| - S/ Vari�vel Global Dentro de Rotinas      |
  +---------------------------------------------+
}  

	const
	  MAX_VERTICES = 24;
	  INFINITO     = 999999;
	
	type
	  TVetorNomes    = Array[1..MAX_VERTICES] of String;
	  TMatrizCusto   = Array[1..MAX_VERTICES, 1..MAX_VERTICES] of Integer;
	  TVetorDist     = Array[1..MAX_VERTICES] of Integer;
	  TVetorVisitado = Array[1..MAX_VERTICES] of Boolean;
	  TVetorAnterior = Array[1..MAX_VERTICES] of Integer; // Rastreia o caminho
	  RegGrafo = Record
	  	Nomes         : TVetorNomes;
	  	MatrizCusto   : TMatrizCusto;
	  	TotalVertices : Integer;
	  end;
	
	var
		Grafo       : RegGrafo;
	  OpcaoMenu   : Integer;  
	  Inicio, Fim : String;

	// Inicializa o grafo vazio de acordo com o algoritmo do maluco
	procedure InicializarGrafo(var oGrafo : RegGrafo);
		var
		  i, j: integer;
	begin
		With oGrafo do
		begin
		  TotalVertices := 0;
		  for i := 1 to MAX_VERTICES do
		    for j := 1 to MAX_VERTICES do
		      if i = j then
		        MatrizCusto[i, j] := 0
		      else
		        MatrizCusto[i, j] := INFINITO;
	  end;
	end;
	
{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- }	
	
	// Incluir Vertice pra gente montar nosso grafo
	procedure IncluirVertice(sNome : String; var oGrafo : RegGrafo);
	begin
	  With oGrafo do
	  begin
		  if TotalVertices < MAX_VERTICES then
		  begin
		    TotalVertices := TotalVertices + 1;
		    Nomes[TotalVertices] := sNome;
		  end
		  else // Nem precisava na real, pois o grafo é pré estabelecido. Mas deixa assim caso nós utilizamos no futuro
		    writeln('Erro: Limite max. de vertices atingido no grafo.');
	  end;
	end;
	
{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- }		
	
	// Funcao auxiliar para encontrar o indice numerico do vertice pelo nome para facilitar a vida
	function BuscarVertice(sNome : String; var oGrafo : RegGrafo) : Integer;
		var
		  i      : Integer;
		  bAchou : Boolean;
	begin
		With oGrafo do
		begin
		  BuscarVertice := 0;
		  bAchou        := False;   		  
		  for i := 1 to TotalVertices do
		    if (Nomes[i] = sNome) and (not bAchou)then
		    begin
		      BuscarVertice := i;
		      bAchou := True;
		    end;
	  end;
	end;
	
{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- }		
	
	// Incluir Aresta pra montar as liga��es malucas
	procedure IncluirAresta(sNomeOrigem, sNomeDestino : String; iPeso : Integer; var oGrafo : RegGrafo);
		var
		  iIndiceOrigem, iIndiceDestino : Integer;
	begin
		With oGrafo do
		begin
		  iIndiceOrigem  := BuscarVertice(sNomeOrigem, oGrafo);
		  iIndiceDestino := BuscarVertice(sNomeDestino, oGrafo);
		
		  if (iIndiceOrigem > 0) and (iIndiceDestino > 0) then
		  begin
		    MatrizCusto[iIndiceOrigem, iIndiceDestino] := iPeso;
		    MatrizCusto[iIndiceDestino, iIndiceOrigem] := iPeso; // o nosso Grafo n eh direcionado, portanto eh necessario repetir o mesmo valor na outra direcao
		  end
		  else
		    writeln('Erro: Algum dos v�rtices informados n�o foram encontrados (', sNomeOrigem, ' -> ', sNomeDestino, ').');
	  end;
	end;
	
{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- }		
	
	// Buscar Menor Caminho (essa deu trabalho p)
	procedure BuscarMenorCaminho(sNomeOrigem, sNomeDestino : String; var oGrafo : RegGrafo);
		var
		  Dist                                  : TVetorDist;
		  Visitado                              : TVetorVisitado;
		  Anterior                              : TVetorAnterior; 
		  iIndiceOrigem, iIndiceDestino, i, v, u, minDist : Integer;
		  CaminhoInverso                        : Array[1..MAX_VERTICES] of Integer;
		  TamanhoCaminho                        : Integer;
		  bEncerrar                             : Boolean;
	begin                           
		With oGrafo do
		begin
		  iIndiceOrigem  := BuscarVertice(sNomeOrigem, oGrafo);
		  iIndiceDestino := BuscarVertice(sNomeDestino, oGrafo);
		
		  if (iIndiceOrigem = 0) or (iIndiceDestino = 0) then
		  begin
		  	TextColor(Red);
		    writeln('Erro: Vertice de origem ou destino nao encontrado.');	    
		  end
		  else
		  begin	
			  // Config inicial
			  for i := 1 to TotalVertices do
			  begin
			    Dist[i] := INFINITO;
			    Visitado[i] := false;
			    Anterior[i] := 0; // 0 = significa que ainda nao tem anterior
			  end;
			  Dist[iIndiceOrigem] := 0;
			
				bEncerrar := False;
			  // Dijkstra
			  for i := 1 to TotalVertices do
			  begin
			  	if not bEncerrar then
			  	begin
				    minDist := INFINITO;
				    u := 0;
				
				    // Encontra o v�rtice n�o visitado com a menor dist�ncia atual
				    for v := 1 to TotalVertices do
				    begin
				      if (not Visitado[v]) and (Dist[v] <= minDist) then
				      begin
				        minDist := Dist[v];
				        u := v;
				      end;
				    end;
				
				    // Se n�o h� mais v�rtices pra ir ele interrompe
				    if (u = 0) or (minDist = INFINITO) then 
							bEncerrar := True;
							
				    if not bEncerrar then
				    begin
					    Visitado[u] := true;
					
					    // Se chegou no fim ja pode parar de procurar
					    if u = iIndiceDestino then 
								bEncerrar := True;
					
							if not bEncerrar then
							begin
						    // Atualiza as dist�ncias dos vizinhos de u
						    for v := 1 to TotalVertices do
						    begin
						      if (not Visitado[v]) and (MatrizCusto[u, v] <> INFINITO) and (Dist[u] <> INFINITO) then
						      begin
						        // Se encontrou um caminho mais curto
						        if Dist[u] + MatrizCusto[u, v] < Dist[v] then
						        begin
						          Dist[v] := Dist[u] + MatrizCusto[u, v];
						          Anterior[v] := u; // Guarda que pra chegar em "v", passou por "u"
						        end;
						      end;
						    end;	    
					    end;
				    end;	    
			  	end;
			  end;
		  end;
		
		  // Caminho
		  writeln;
		  writeln('=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=');
		  TextColor(White);
		  write('Menor Caminho Calculado de "');  
		  TextColor(LightBlue);
			write(sNomeOrigem);  
		  TextColor(White);
			write('" para "'); 
		  TextColor(LightBlue);
			write(sNomeDestino);  
		  TextColor(White);
			writeln('"');
		  
		  if Dist[iIndiceDestino] = INFINITO then
		  begin
		  	TextColor(Red);
		    writeln('Nao existe caminho poss�vel entre os vertices.');
		  end
		  else
		  begin         
		  	TextColor(White);
		    write(' > Custo Total (Dist�ncia): ');    
		  	TextColor(LightBlue);
				writeln(Dist[iIndiceDestino]);
		    
		    TamanhoCaminho := 0;
		    u := iIndiceDestino;
		    
		    while u <> 0 do
		    begin
		      TamanhoCaminho := TamanhoCaminho + 1;
		      CaminhoInverso[TamanhoCaminho] := u;
		      u := Anterior[u]; // Pega quem veio antes dele
		    end;
		
		    // Como o vetor foi preenchido do destino pra origem fica o contraio    
		  	TextColor(White);
		    write(' > Rota Calculada.........: ');
		    for i := TamanhoCaminho downto 1 do
		    begin
		    	TextColor(LightBlue);
		      write(Nomes[CaminhoInverso[i]]);    
		    	TextColor(DarkGray);
		      if i > 1 then 
						write(' -> ');
		    end;
		    writeln;
		  end;
	  end;
	end;
	
{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- }		

	procedure MostrarMatrizCusto(var oGrafo : RegGrafo);
		var
			i, j : Integer;
	begin           
		With oGrafo do
		begin      		
		  TextColor(LightGreen);   
		  writeln('=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=');
			writeln('                               __  ____  __  . ____ '+#13#10+
							'                         |\/| |__|  |   |  \ |    / ');
			writeln('                         |  | |  |  |   |__/ |   /  '+#13#10+
							'                         |  | |  |  |   |  \ |  /__ '+#13#10);  
	
		  TextColor(Green);  						
		  write('     ');
		  for i:= 1 to MAX_VERTICES do
		  	Write('  ',Nomes[i],'   ');
		  writeln;                          
		  writeln('----------------------------------------------------------------------------------------------------------------------------------------------------');
		  
		  for i:= 1 to MAX_VERTICES do
		  begin
		    TextColor(Green);
		    Write(' ',Nomes[i],' | ');
				for j:= 1 to MAX_VERTICES do
					if (MatrizCusto[i,j] <> INFINITO) and (MatrizCusto[i,j] <> 0) then
					begin
						TextColor(White);
						write(MatrizCusto[i,j]:5:0, ' ');
					end
					else
					begin
						textcolor(DarkGray); 
						write('  *   ');
					end;
					
				writeln;
			end;   
		  TextColor(LightGreen);   
		  writeln(#13#10+'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=');
	  end;
	end;   
	                
{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- }	
	
	procedure CarregaVertices(var oGrafo : RegGrafo);
	begin  
		// Testando IncluirVertice | A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X |
		IncluirVertice('A', oGrafo);    
		IncluirVertice('B', oGrafo);
		IncluirVertice('C', oGrafo);
		IncluirVertice('D', oGrafo);
		IncluirVertice('E', oGrafo);    
		IncluirVertice('F', oGrafo);
		IncluirVertice('G', oGrafo);
		IncluirVertice('H', oGrafo);
		IncluirVertice('I', oGrafo);
		IncluirVertice('J', oGrafo);
		IncluirVertice('K', oGrafo);
		IncluirVertice('L', oGrafo);
		IncluirVertice('M', oGrafo);
		IncluirVertice('N', oGrafo);
		IncluirVertice('O', oGrafo);
		IncluirVertice('P', oGrafo);
		IncluirVertice('Q', oGrafo);
		IncluirVertice('R', oGrafo);
		IncluirVertice('S', oGrafo);
		IncluirVertice('T', oGrafo);
		IncluirVertice('U', oGrafo);
		IncluirVertice('V', oGrafo);
		IncluirVertice('W', oGrafo);  
		IncluirVertice('X', oGrafo);
	end;     
	                
{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- }	
	
	procedure CarregaArestas(var oGrafo : RegGrafo);
	begin 
		// A
		IncluirAresta('A', 'B', 40,  oGrafo);
		IncluirAresta('A', 'C', 40,  oGrafo);
		IncluirAresta('A', 'D', 120, oGrafo);
		IncluirAresta('A', 'E', 120, oGrafo);
		IncluirAresta('A', 'L', 50,  oGrafo);
		IncluirAresta('A', 'O', 50,  oGrafo);
		IncluirAresta('A', 'Q', 150, oGrafo);
		IncluirAresta('A', 'S', 50,  oGrafo);
		IncluirAresta('A', 'U', 50,  oGrafo);
		IncluirAresta('A', 'W', 150, oGrafo);
		// B
		IncluirAresta('B', 'D', 80, oGrafo);
		// C                        
		IncluirAresta('C', 'E', 80, oGrafo);
		// D                        
		IncluirAresta('D', 'F', 10, oGrafo);
		IncluirAresta('D', 'J', 30, oGrafo);
		IncluirAresta('D', 'L', 20, oGrafo);
		IncluirAresta('D', 'N', 15, oGrafo);
		// E                        
		IncluirAresta('E', 'G', 15, oGrafo);
		IncluirAresta('E', 'I', 10, oGrafo);
		IncluirAresta('E', 'M', 30, oGrafo);
		IncluirAresta('E', 'O', 20, oGrafo);
		// F                        
		IncluirAresta('F', 'H', 40, oGrafo);
		IncluirAresta('F', 'L', 30, oGrafo);
		IncluirAresta('F', 'N', 20, oGrafo);
		IncluirAresta('F', 'V', 200, oGrafo);
		// G
		IncluirAresta('G', 'I', 20, oGrafo);
		// H
		IncluirAresta('H', 'J', 50, oGrafo);
		// I
		IncluirAresta('I', 'K', 40,  oGrafo);
		IncluirAresta('I', 'O', 30,  oGrafo);
		IncluirAresta('I', 'V', 200, oGrafo);
		// J
		IncluirAresta('J', 'L', 10, oGrafo);
		IncluirAresta('J', 'O', 30, oGrafo);
		IncluirAresta('J', 'V', 50, oGrafo);
		// K
		IncluirAresta('K', 'M', 50, oGrafo);
		// L
		IncluirAresta('L', 'M', 30, oGrafo);
		IncluirAresta('L', 'O', 20, oGrafo);
		// M
		IncluirAresta('M', 'O', 10, oGrafo);
		IncluirAresta('M', 'V', 50, oGrafo);
		// N
		IncluirAresta('N', 'P', 10, oGrafo);
		IncluirAresta('N', 'X', 5,  oGrafo);
		// P
		IncluirAresta('P', 'R', 10, oGrafo);
		// Q
		IncluirAresta('Q', 'S', 20, oGrafo);
		IncluirAresta('Q', 'U', 70, oGrafo);
		// R
		IncluirAresta('R', 'T', 10, oGrafo);
		// S
		IncluirAresta('S', 'U', 20, oGrafo);
		IncluirAresta('S', 'W', 70, oGrafo);
		// T
		IncluirAresta('T', 'X', 10, oGrafo);
		// U
		IncluirAresta('U', 'W', 20, oGrafo); 
	end;

{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- }	

begin
  InicializarGrafo(Grafo);
	CarregaVertices(Grafo);
	CarregaArestas(Grafo);
	  
  OpcaoMenu := -1;
	while OpcaoMenu <> 0 do
	begin  	
		TextColor(LightGreen);
		writeln('=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=');
		WriteLn('      ___           '+#13#10+
						'|\/| |    |\  | |  |'+#13#10+
						'|  | |-   | \ | |  |'+#13#10+
						'|  | |___ |  \| \__/'+#13#10);	
		WriteLn(' - 1 - Calcular distancia entre os vertices informados'+#13#10+
		        ' - 2 - Visualizar a matriz de custo gerada do algoritmo'+#13#10+#13#10+
		        ' - 0 - Finalizar Execucao'+#13#10);
		
		Write('> Informe a opcao do menu: ');
		ReadLn(OpcaoMenu);
		WriteLn('------------------');
		
		case OpcaoMenu of
		  1 : begin
				    // Testando o BuscarMenorCaminho
				    Write(' > |INICIO| Informe o vertice de inicio da busca: ');  
				    ReadLn(Inicio);                
				    Write(' > |  FIM | Informe o vertice de fim da busca...: ');  
				    ReadLn(Fim);                                         
				    BuscarMenorCaminho(Inicio, Fim, Grafo);
		      end;
		  2 : MostrarMatrizCusto(Grafo);
		  0 : Writeln;
		  else
		  	TextColor(Red);
		  	Writeln('Informe uma opcao valida para o menu!');
		end;
	end;
	
end.
