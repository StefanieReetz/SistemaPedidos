object frmPrincipal: TfrmPrincipal
  Left = 0
  Top = 180
  Caption = 'Sistema de Pedidos'
  ClientHeight = 566
  ClientWidth = 848
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poDesigned
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 848
    Height = 566
    ActivePage = tsCatalogo
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 798
    ExplicitHeight = 532
    object tsCatalogo: TTabSheet
      Caption = 'Produtos e Servi'#231'os'
      object lvCatalogo: TListView
        Left = 0
        Top = 0
        Width = 840
        Height = 406
        Align = alClient
        Columns = <
          item
            Caption = 'C'#243'digo'
            Width = 60
          end
          item
            Caption = 'Tipo'
            Width = 80
          end
          item
            Caption = 'Descri'#231#227'o'
            Width = 330
          end
          item
            Alignment = taRightJustify
            Caption = 'Pre'#231'o'
            Width = 100
          end
          item
            Caption = 'Detalhe'
            Width = 150
          end>
        GridLines = True
        HideSelection = False
        ReadOnly = True
        RowSelect = True
        TabOrder = 0
        ViewStyle = vsReport
        OnSelectItem = lvCatalogoSelectItem
        ExplicitWidth = 792
        ExplicitHeight = 380
      end
      object pnlCadastro: TPanel
        Left = 0
        Top = 406
        Width = 840
        Height = 130
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 1
        ExplicitTop = 372
        ExplicitWidth = 790
        object lblDescricao: TLabel
          Left = 150
          Top = 8
          Width = 51
          Height = 15
          Caption = 'Descri'#231#227'o'
        end
        object lblPreco: TLabel
          Left = 460
          Top = 8
          Width = 30
          Height = 15
          Caption = 'Pre'#231'o'
        end
        object lblUnidade: TLabel
          Left = 570
          Top = 8
          Width = 44
          Height = 15
          Caption = 'Unidade'
        end
        object lblDuracao: TLabel
          Left = 640
          Top = 8
          Width = 76
          Height = 15
          Caption = 'Dura'#231#227'o (min)'
        end
        object rgTipo: TRadioGroup
          Left = 8
          Top = 6
          Width = 130
          Height = 64
          Caption = 'Tipo'
          ItemIndex = 0
          Items.Strings = (
            'Produto'
            'Servi'#231'o')
          TabOrder = 0
          OnClick = rgTipoClick
        end
        object edtDescricao: TEdit
          Left = 150
          Top = 26
          Width = 300
          Height = 23
          MaxLength = 100
          TabOrder = 1
        end
        object edtPreco: TEdit
          Left = 460
          Top = 26
          Width = 100
          Height = 23
          TabOrder = 2
        end
        object edtUnidade: TEdit
          Left = 570
          Top = 26
          Width = 60
          Height = 23
          MaxLength = 5
          TabOrder = 3
        end
        object edtDuracao: TEdit
          Left = 640
          Top = 26
          Width = 90
          Height = 23
          NumbersOnly = True
          TabOrder = 4
        end
        object btnNovo: TButton
          Left = 8
          Top = 84
          Width = 100
          Height = 30
          Caption = 'Novo'
          TabOrder = 5
          OnClick = btnNovoClick
        end
        object btnSalvar: TButton
          Left = 116
          Top = 84
          Width = 100
          Height = 30
          Caption = 'Salvar'
          TabOrder = 6
          OnClick = btnSalvarClick
        end
        object btnExcluir: TButton
          Left = 224
          Top = 84
          Width = 100
          Height = 30
          Caption = 'Excluir'
          TabOrder = 7
          OnClick = btnExcluirClick
        end
      end
    end
    object tsPedido: TTabSheet
      Caption = 'Novo Pedido'
      ImageIndex = 1
      object pnlTopoPedido: TPanel
        Left = 0
        Top = 0
        Width = 840
        Height = 64
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        ExplicitWidth = 792
        object lblCliente: TLabel
          Left = 8
          Top = 6
          Width = 37
          Height = 15
          Caption = 'Cliente'
        end
        object lblItem: TLabel
          Left = 240
          Top = 6
          Width = 24
          Height = 15
          Caption = 'Item'
        end
        object lblQuantidade: TLabel
          Left = 550
          Top = 6
          Width = 62
          Height = 15
          Caption = 'Quantidade'
        end
        object edtCliente: TEdit
          Left = 8
          Top = 24
          Width = 220
          Height = 23
          MaxLength = 100
          TabOrder = 0
        end
        object cbItem: TComboBox
          Left = 240
          Top = 24
          Width = 300
          Height = 23
          Style = csDropDownList
          TabOrder = 1
        end
        object edtQuantidade: TEdit
          Left = 550
          Top = 24
          Width = 70
          Height = 23
          TabOrder = 2
          Text = '1'
        end
        object btnAdicionar: TButton
          Left = 630
          Top = 23
          Width = 100
          Height = 25
          Caption = 'Adicionar'
          TabOrder = 3
          OnClick = btnAdicionarClick
        end
      end
      object lvItensPedido: TListView
        Left = 0
        Top = 64
        Width = 840
        Height = 422
        Align = alClient
        Columns = <
          item
            Caption = 'Tipo'
            Width = 80
          end
          item
            Caption = 'Descri'#231#227'o'
            Width = 320
          end
          item
            Alignment = taRightJustify
            Caption = 'Qtde'
            Width = 80
          end
          item
            Alignment = taRightJustify
            Caption = 'Pre'#231'o Unit.'
            Width = 100
          end
          item
            Alignment = taRightJustify
            Caption = 'Subtotal'
            Width = 110
          end>
        GridLines = True
        HideSelection = False
        ReadOnly = True
        RowSelect = True
        TabOrder = 1
        ViewStyle = vsReport
        ExplicitWidth = 792
        ExplicitHeight = 396
      end
      object pnlRodapePedido: TPanel
        Left = 0
        Top = 486
        Width = 840
        Height = 50
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 2
        ExplicitTop = 460
        ExplicitWidth = 792
        object lblTotal: TLabel
          Left = 8
          Top = 14
          Width = 100
          Height = 21
          Caption = 'Total: R$ 0,00'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object btnRemover: TButton
          Left = 470
          Top = 10
          Width = 120
          Height = 30
          Caption = 'Remover item'
          TabOrder = 0
          OnClick = btnRemoverClick
        end
        object btnFinalizar: TButton
          Left = 600
          Top = 10
          Width = 130
          Height = 30
          Caption = 'Finalizar pedido'
          TabOrder = 1
          OnClick = btnFinalizarClick
        end
      end
    end
    object tsPedidos: TTabSheet
      Caption = 'Pedidos Realizados'
      ImageIndex = 2
      object lvPedidos: TListView
        Left = 0
        Top = 0
        Width = 840
        Height = 536
        Align = alClient
        Columns = <
          item
            Caption = 'N'#186
            Width = 60
          end
          item
            Caption = 'Data'
            Width = 120
          end
          item
            Caption = 'Cliente'
            Width = 300
          end
          item
            Alignment = taRightJustify
            Caption = 'Itens'
            Width = 60
          end
          item
            Alignment = taRightJustify
            Caption = 'Total'
            Width = 110
          end>
        GridLines = True
        HideSelection = False
        ReadOnly = True
        RowSelect = True
        TabOrder = 0
        ViewStyle = vsReport
        OnDblClick = lvPedidosDblClick
        ExplicitWidth = 792
        ExplicitHeight = 510
      end
    end
  end
end
